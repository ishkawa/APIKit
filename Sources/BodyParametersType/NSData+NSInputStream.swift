import Foundation

enum InputStreamError: Error {
    case InvalidDataCapacity(Int)
    case UnreadableStream(InputStream)
}

extension Data {
    init(inputStream: InputStream, capacity: Int = Int(UInt16.max)) throws {
        var data = Data(capacity: capacity)

        let bufferSize = Swift.min(Int(UInt16.max), capacity)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

        var readSize: Int

        repeat {
            readSize = inputStream.read(buffer, maxLength: bufferSize)

            switch readSize {
            case let x where x > 0:
                data.append(buffer, count: readSize)

            case let x where x < 0:
                throw InputStreamError.UnreadableStream(inputStream)

            default:
                break
            }
        } while readSize > 0

        buffer.deallocate(capacity: bufferSize)

        self.init(data)
    }
}
