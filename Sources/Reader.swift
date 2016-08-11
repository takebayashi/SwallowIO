#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

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

    public func readUntil(token: [Entry]) throws -> [Entry] {
        var buffer = [Entry]()
        while let entry = try read() {
            buffer.append(entry)
            if [Entry](buffer.suffix(token.count)) == token {
                break
            }
        }
        return buffer
    }

}
