import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
    import MobileCoreServices
#elseif os(OSX)
    import CoreServices
#endif

/// `FormURLEncodedBodyParameters` serializes array of `Part` for HTTP body and states its content type is multipart/form-data.
public struct MultipartFormDataBodyParameters: BodyParametersType {
    public enum EntityType {
        case InputStream
        case Data
    }

    public let parts: [Part]
    public let boundary: String
    public let entityType: EntityType

    public init(parts: [Part], boundary: String = String(format: "%08x%08x", arc4random(), arc4random()), entityType: EntityType = .InputStream) {
        self.parts = parts
        self.boundary = boundary
        self.entityType = entityType
    }

    // MARK: BodyParametersType
    public var contentType: String {
        return "multipart/form-data; boundary=\(boundary)"
    }

    public func buildEntity() throws -> RequestBodyEntity {
        let inputStream = MultipartInputStream(parts: parts, boundary: boundary)

        switch entityType {
        case .InputStream:
            return .InputStream(inputStream)

        case .Data:
            return .Data(try NSData(inputStream: inputStream))
        }
    }
}

public extension MultipartFormDataBodyParameters {
    /// Part represents single part of multipart/form-data.
    public struct Part {
        public enum Error: ErrorType {
            case IllegalValue(Any)
            case IllegalFileURL(NSURL)
            case CannotGetFileSize(NSURL)
        }

        public let inputStream: NSInputStream
        public let name: String
        public let mimeType: String?
        public let fileName: String?
        public let length: Int

        /// Returns Part instance that has data presentation of passed value.
        /// `value` will be converted via `String(_:)` and serialized via `String.dataUsingEncoding(_:)`.
        /// If `mimeType` or `fileName` are `nil`, the fields will be omitted.
        public init(value: Any, name: String, mimeType: String? = nil, fileName: String? = nil, encoding: NSStringEncoding = NSUTF8StringEncoding) throws {
            guard let data = String(value).dataUsingEncoding(encoding) else {
                throw Error.IllegalValue(value)
            }

            self.inputStream = NSInputStream(data: data)
            self.name = name
            self.mimeType = mimeType
            self.fileName = fileName
            self.length = data.length
        }

        /// Returns Part instance that has input stream of specifed data.
        /// If `mimeType` or `fileName` are `nil`, the fields will be omitted.
        public init(data: NSData, name: String, mimeType: String? = nil, fileName: String? = nil) {
            self.inputStream = NSInputStream(data: data)
            self.name = name
            self.mimeType = mimeType
            self.fileName = fileName
            self.length = data.length
        }

        /// Returns Part instance that has input stream of specifed file URL.
        /// If `mimeType` or `fileName` are `nil`, values for the fields will be detected from URL.
        public init(fileURL: NSURL, name: String, mimeType: String? = nil, fileName: String? = nil) throws {
            guard let inputStream = NSInputStream(URL: fileURL) else {
                throw Error.IllegalFileURL(fileURL)
            }

            let fileSize = fileURL.path
                .flatMap { try? NSFileManager.defaultManager().attributesOfItemAtPath($0) }
                .flatMap { $0[NSFileSize] as? NSNumber }
                .map { $0.integerValue }

            guard let bodyLength = fileSize else {
                throw Error.CannotGetFileSize(fileURL)
            }

            let detectedMimeType = fileURL.pathExtension
                .flatMap { UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, $0, nil)?.takeRetainedValue() }
                .flatMap { UTTypeCopyPreferredTagWithClass($0, kUTTagClassMIMEType)?.takeRetainedValue() }
                .map { $0 as String }

            self.inputStream = inputStream
            self.name = name
            self.mimeType = mimeType ?? detectedMimeType ?? "application/octet-stream"
            self.fileName = fileName ?? fileURL.lastPathComponent
            self.length = bodyLength
        }
    }

    internal class PartInputStream: AbstractInputStream {
        let headerData: NSData
        let footerData: NSData
        let bodyPart: Part

        let totalLength: Int
        var totalSentLength: Int

        init(part: Part, boundary: String) {
            let header: String
            switch (part.mimeType, part.fileName) {
            case (let mimeType?, let fileName?):
                header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(fileName)\"\r\nContent-Type: \(mimeType)\r\n\r\n"

            case (let mimeType?, _):
                header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(part.name)\"; \r\nContent-Type: \(mimeType)\r\n\r\n"

            default:
                header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(part.name)\"\r\n\r\n"
            }

            headerData = header.dataUsingEncoding(NSUTF8StringEncoding)!
            footerData = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
            bodyPart = part
            totalLength = headerData.length + bodyPart.length + footerData.length
            totalSentLength = 0

            super.init()
        }

        var headerRange: Range<Int> {
            return 0..<headerData.length
        }

        var bodyRange: Range<Int> {
            return headerRange.endIndex..<(headerRange.endIndex + bodyPart.length)
        }

        var footerRange: Range<Int> {
            return bodyRange.endIndex..<(bodyRange.endIndex + footerData.length)
        }

        // MARK: NSInputStream
        override var hasBytesAvailable: Bool {
            return totalSentLength < totalLength
        }

        override func read(buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
            var sentLength = 0

            while sentLength < maxLength && totalSentLength < totalLength {
                let offsetBuffer = buffer + sentLength
                let availableLength = maxLength - sentLength

                switch totalSentLength {
                case headerRange:
                    let readLength = min(headerRange.endIndex - totalSentLength, availableLength)
                    let readRange = NSRange(location: totalSentLength - headerRange.startIndex, length: readLength)
                    headerData.getBytes(offsetBuffer, range: readRange)
                    sentLength += readLength
                    totalSentLength += sentLength

                case bodyRange:
                    if bodyPart.inputStream.streamStatus == .NotOpen {
                        bodyPart.inputStream.open()
                    }

                    let readLength = bodyPart.inputStream.read(offsetBuffer, maxLength: availableLength)
                    sentLength += readLength
                    totalSentLength += readLength

                case footerRange:
                    let readLength = min(footerRange.endIndex - totalSentLength, availableLength)
                    let range = NSRange(location: totalSentLength - footerRange.startIndex, length: readLength)
                    footerData.getBytes(offsetBuffer, range: range)
                    sentLength += readLength
                    totalSentLength += readLength

                default:
                    print("Illegal range access: \(totalSentLength) is out of \(headerRange.startIndex)..<\(footerRange.endIndex)")
                    return -1
                }
            }

            return sentLength;
        }
    }

    internal class MultipartInputStream: AbstractInputStream {
        let boundary: String
        let partStreams: [PartInputStream]
        let footerData: NSData

        let totalLength: Int
        var totalSentLength: Int

        private var privateStreamStatus = NSStreamStatus.NotOpen

        init(parts: [Part], boundary: String) {
            self.boundary = boundary
            self.partStreams = parts.map { PartInputStream(part: $0, boundary: boundary) }
            self.footerData = "--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!
            self.totalLength = partStreams.reduce(footerData.length) { $0 + $1.totalLength }
            self.totalSentLength = 0
            super.init()
        }

        var partsRange: Range<Int> {
            return 0..<partStreams.reduce(0) { $0 + $1.totalLength }
        }

        var footerRange: Range<Int> {
            return partsRange.endIndex..<(partsRange.endIndex + footerData.length)
        }

        var currentPartInputStream: PartInputStream? {
            var currentOffset = 0

            for partStream in partStreams {
                let partStreamRange = currentOffset..<(currentOffset + partStream.totalLength)
                if partStreamRange.contains(totalSentLength) {
                    return partStream
                }

                currentOffset += partStream.totalLength
            }

            return nil
        }

        // MARK: NSInputStream
        // NOTE: NSInputStream does not have its own implementation because it is a class cluster.
        override var streamStatus: NSStreamStatus {
            return privateStreamStatus
        }

        override var hasBytesAvailable: Bool {
            return totalSentLength < totalLength
        }

        override func open() {
            privateStreamStatus = .Open
        }

        override func close() {
            privateStreamStatus = .Closed
        }

        override func read(buffer: UnsafeMutablePointer<UInt8>, maxLength: Int) -> Int {
            privateStreamStatus = .Reading

            var sentLength = 0

            while sentLength < maxLength && totalSentLength < totalLength {
                let offsetBuffer = buffer + sentLength
                let availableLength = maxLength - sentLength

                switch totalSentLength {
                case partsRange:
                    guard let partStream = currentPartInputStream else {
                        print("Illegal offset \(totalLength) for part streams \(partsRange)")
                        return -1
                    }

                    let readLength = partStream.read(offsetBuffer, maxLength: availableLength)
                    sentLength += readLength
                    totalSentLength += readLength

                case footerRange:
                    let readLength = min(footerRange.endIndex - totalSentLength, availableLength)
                    let range = NSRange(location: totalSentLength - footerRange.startIndex, length: readLength)
                    footerData.getBytes(offsetBuffer, range: range)
                    sentLength += readLength
                    totalSentLength += readLength

                default:
                    print("Illegal range access: \(totalSentLength) is out of \(partsRange.startIndex)..<\(footerRange.endIndex)")
                    return -1
                }

                if privateStreamStatus != .Closed && !hasBytesAvailable {
                    privateStreamStatus = .AtEnd
                }
            }

            return sentLength
        }

        override var delegate: NSStreamDelegate? {
            get { return nil }
            set { }
        }

        override func scheduleInRunLoop(runLoop: NSRunLoop, forMode mode: String) {

        }

        override func removeFromRunLoop(runLoop: NSRunLoop, forMode mode: String) {

        }
    }
}
