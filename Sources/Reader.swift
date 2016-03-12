#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

enum ReaderError: ErrorType {
    case GenericError(error: Int32)
}

public protocol Reader: class {

    associatedtype Entry

    func read() throws -> Entry?

    func read(maxLength: Int) throws -> [Entry]

}


public extension Reader {

    public func read(maxLength: Int) throws -> [Entry] {
        var entries = [Entry]()
        for _ in 0..<maxLength {
            if let entry = try self.read() {
                entries.append(entry)
            }
        }
        return entries
    }

}

public extension Reader where Entry: Equatable {

    public func read(until suffix: [Entry]) throws -> [Entry] {
        var buffer = [Entry]()
        while let entry = try read() {
            buffer.append(entry)
            if [Entry](buffer.suffix(suffix.count)) == suffix {
                break
            }
        }
        return buffer
    }

}

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

public class BufferedReader<R: Reader where R.Entry: Equatable>: Reader {

    public typealias Entry = [R.Entry]

    var reader: R

    let delimiter: R.Entry

    public init(reader: R, delimiter: R.Entry) {
        self.reader = reader
        self.delimiter = delimiter
    }

    var buffer = Entry()

    var reading = true

    func flush() -> Entry? {
        let size = buffer.count
        for i in 0..<size {
            if buffer[i] == delimiter {
                let line = Entry(buffer[0...i])
                if i + 1 >= size {
                    buffer = []
                }
                else {
                    buffer = Entry(buffer[(i + 1)..<size])
                }
                return line
            }
        }
        return nil
    }

    public func read() throws -> Entry? {
        if let line = flush() {
            return line
        }
        let batch = 128
        while reading {
            let chunk = try reader.read(batch)
            if chunk.count == 0 {
                reading = false
            }
            else if chunk.count < batch {
                reading = false
            }
            buffer.appendContentsOf(chunk)
            if let line = flush() {
                return line
            }
        }
        if buffer.count > 0 {
            let line = buffer
            buffer.removeAll()
            return line
        }
        return nil
    }

}

public class LineBufferedReader<R: Reader where R.Entry == Byte>: BufferedReader<R> {

    public init(reader: R, delimiter: Byte = Byte(10)) {
        super.init(reader: reader, delimiter: delimiter)
    }

}
