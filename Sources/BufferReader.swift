public class BufferReader<E>: Reader {

    public typealias Entry = E

    var buffer: [Entry]

    public init(buffer: [Entry]) {
        self.buffer = buffer
    }

    public func read() throws -> Entry? {
        if let first = buffer.first {
            buffer = [Entry](buffer[1..<buffer.endIndex])
            return first
        }
        return nil
    }

}
