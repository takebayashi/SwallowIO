import C7

public class BufferedReader<R: Reader>: Reader where R.Entry: Equatable {

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
            let chunk = try reader.read(maxLength: batch)
            if chunk.count == 0 {
                reading = false
            }
            else if chunk.count < batch {
                reading = false
            }
            buffer.append(contentsOf: chunk)
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

public class LineBufferedReader<R: Reader>: BufferedReader<R> where R.Entry == C7.Byte {

    override public init(reader: R, delimiter: R.Entry = C7.Byte(10)) {
        super.init(reader: reader, delimiter: delimiter)
    }

}
