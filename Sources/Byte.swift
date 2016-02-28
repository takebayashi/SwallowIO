public typealias Byte = UInt8
public typealias Bytes = [Byte]

public extension CollectionType where Generator.Element == Byte {

    public func toString() -> String? {
        return withCCharBufferPointer { buffer in
            return String.fromCString(buffer.baseAddress)
        }
    }

    func withCCharBufferPointer<T>(proc: (UnsafeBufferPointer<CChar>) -> T) -> T {
        let array = [CChar](self.map{ return CChar($0) })
        return array.withUnsafeBufferPointer { buffer in
            return proc(buffer)
        }
    }

}
