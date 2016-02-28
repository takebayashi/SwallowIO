#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

enum ReaderError: ErrorType {
    case GenericError(error: Int32)
}

public protocol Reader {

    typealias Entry

    mutating func read() throws -> Entry?

    mutating func read(maxLength: Int) throws -> [Entry]

}


extension Reader {

    mutating func read(maxLength: Int) throws -> [Entry] {
        var entries = [Entry]()
        for _ in 0..<maxLength {
            if let entry = try self.read() {
                entries.append(entry)
            }
        }
        return entries
    }

}

class BufferReader<E>: Reader {

    typealias Entry = E

    var buffer: [Entry]

    init(buffer: [Entry]) {
        self.buffer = buffer
    }

    func read() throws -> Entry? {
        if let first = buffer.first {
            buffer = [Entry](buffer[1..<buffer.endIndex])
            return first
        }
        return nil
    }

}

class BufferedReader<R: Reader where R.Entry: Equatable>: Reader {

    typealias Entry = [R.Entry]

    var reader: R

    let delimiter: R.Entry

    init(reader: R, delimiter: R.Entry) {
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

    func read() throws -> Entry? {
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

class LineBufferedReader<R: Reader where R.Entry == UInt8>: BufferedReader<R> {

    init(reader: R, delimiter: UInt8 = UInt8(10)) {
        super.init(reader: reader, delimiter: delimiter)
    }

}
