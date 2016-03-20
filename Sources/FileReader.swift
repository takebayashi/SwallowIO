#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public class FileReader: Reader {

    public typealias Entry = UInt8

    let fileDescriptor: FileDescriptor

    public init(fileDescriptor: FileDescriptor) {
        self.fileDescriptor = fileDescriptor
    }

    public func read() throws -> Entry? {
        return try read(1).first
    }

    public func read(maxLength: Int) throws -> [Entry] {
        let buffer = UnsafeMutablePointer<Entry>(allocatingCapacity: maxLength)
        memset(buffer, 0, maxLength)
        let size = recv(fileDescriptor.rawDescriptor, buffer, maxLength, 0)
        if size < 0 {
            throw ReaderError.GenericError(error: errno)
        }
        var bytes = [Entry]()
        for i in 0..<size {
            bytes.append(buffer[i])
        }
        buffer.deallocateCapacity(maxLength)
        return bytes
    }

}
