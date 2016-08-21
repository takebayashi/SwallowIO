import C7

#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

extension FileDescriptor {
    
    // AsyncSending
    
    public func send(_ data: Data,
                     timingOut deadline: Double,
                     completion: ((Void) throws -> Void) -> Void) {
        completion {
            try data.withUnsafeBufferPointer { bytes in
                let result = write(self.rawDescriptor, bytes.baseAddress, bytes.count)
                if result < 0 {
                    throw IOError.GenericError(code: errno)
                }
            }
        }
    }
    
    public func flush(timingOut deadline: Double, completion: ((Void) throws -> Void) -> Void) {
        
    }
    
    // Sending
    
    public func send(_ data: Data, timingOut deadline: Double) throws {
        try data.withUnsafeBufferPointer { bytes in
            let result = write(self.rawDescriptor, bytes.baseAddress, bytes.count)
            if result < 0 {
                throw IOError.GenericError(code: errno)
            }
        }
    }
    
    public func flush(timingOut deadline: Double) throws {
    }
    
    // AsyncReceiving
    
    public func receive(upTo byteCount: Int,
                        timingOut deadline: Double,
                        completion: ((Void) throws -> Data) -> Void) {
        completion {
            let buffer = UnsafeMutablePointer<Byte>.allocate(capacity: byteCount)
            memset(buffer, 0, byteCount)
            let size = recv(self.rawDescriptor, buffer, byteCount, 0)
            if size < 0 {
                throw IOError.GenericError(code: errno)
            }
            var bytes = [Byte]()
            for i in 0..<size {
                bytes.append(buffer[i])
            }
            buffer.deallocate(capacity: byteCount)
            return Data(bytes)
        }
    }
    
    // Receiving
    
    public func receive(upTo byteCount: Int, timingOut deadline: Double) throws -> Data {
        let buffer = UnsafeMutablePointer<Byte>.allocate(capacity: byteCount)
        memset(buffer, 0, byteCount)
        let size = read(self.rawDescriptor, buffer, byteCount)
        if size < 0 {
            throw IOError.GenericError(code: errno)
        }
        var bytes = [Byte]()
        for i in 0..<size {
            bytes.append(buffer[i])
        }
        buffer.deallocate(capacity: byteCount)
        return Data(bytes)
    }

}
