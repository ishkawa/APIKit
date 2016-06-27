import Foundation

enum InputStreamError: ErrorType {
    case InvalidDataCapacity(Int)
    case UnreadableStream(NSInputStream)
}

extension NSData {
    convenience init(inputStream: NSInputStream, capacity: Int = Int(UInt16.max)) throws {
        guard let data = NSMutableData(capacity: capacity) else {
            throw InputStreamError.InvalidDataCapacity(capacity)
        }

        let bufferSize = min(Int(UInt16.max), capacity)
        let buffer = UnsafeMutablePointer<UInt8>.alloc(bufferSize)

        var readSize: Int

        repeat {
            readSize = inputStream.read(buffer, maxLength: bufferSize)

            switch readSize {
            case let x where x > 0:
                data.appendBytes(buffer, length: readSize)

            case let x where x < 0:
                throw InputStreamError.UnreadableStream(inputStream)

            default:
                break
            }
        } while readSize > 0

        buffer.dealloc(bufferSize)

        self.init(data: data)
    }
}
