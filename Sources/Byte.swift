public typealias Byte = UInt8
public typealias Bytes = [Byte]

public extension CollectionType where Generator.Element == Byte {

    public func toString() -> String? {
        return withCCharBufferPointer { buffer in
            return String.fromCString(buffer.baseAddress)
        }
    }

    public func nullTerminated() -> [Byte] {
        var copied = [Byte](self)
        if (copied.last ?? 1) != 0 {
            copied.append(0)
        }
        return copied
    }

    func withCCharBufferPointer<T>(proc: (UnsafeBufferPointer<CChar>) -> T) -> T {
        let array = [CChar](self.map{ return CChar($0) })
        return array.withUnsafeBufferPointer { buffer in
            return proc(buffer)
        }
    }

}
