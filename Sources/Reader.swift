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

class BufferReader: Reader {

    typealias Entry = UInt8

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

    func read(maxLength: Int) throws -> [Entry] {
        var bytes = [Entry]()
        for _ in 0..<maxLength {
            if let byte = try self.read() {
                bytes.append(byte)
            }
        }
        return bytes
    }

}

let LF = UInt8(10)

class BufferedReader<R: Reader where R.Entry == UInt8>: Reader {

    typealias Entry = [R.Entry]

    var reader: R

    init(reader: R) {
        self.reader = reader
    }

    var buffer = Entry()

    var reading = true

    func flush() -> Entry? {
        let size = buffer.count
        for i in 0..<size {
            if buffer[i] == LF {
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

    func read(maxLength: Int) throws -> [Entry] {
        var lines = [Entry]()
        for _ in 0..<maxLength {
            if let line = try read() {
                lines.append(line)
            }
            else {
                break
            }
        }
        return lines
    }

}
