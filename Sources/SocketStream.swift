import C7

#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
    let syscall_send = Darwin.send
#elseif os(Linux)
    import Glibc
    let syscall_send = Glibc.send
#endif

extension FileDescriptor {
    
    // AsyncSending
    
    public func send(_ data: Data,
                     timingOut deadline: Double,
                     completion: ((Void) throws -> Void) -> Void) {
        completion {
            try data.withUnsafeBufferPointer { bytes in
                let result = syscall_send(self.rawDescriptor, bytes.baseAddress, bytes.count, 0)
                if result < 0 {
                    throw SocketError.GenericError(code: errno)
                }
            }
        }
    }
    
    public func flush(timingOut deadline: Double, completion: ((Void) throws -> Void) -> Void) {
        
    }
    
    // Sending
    
    public func send(_ data: Data, timingOut deadline: Double) throws {
        try data.withUnsafeBufferPointer { bytes in
            let result = syscall_send(self.rawDescriptor, bytes.baseAddress, bytes.count, 0)
            if result < 0 {
                throw SocketError.GenericError(code: errno)
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
                throw ReaderError.GenericError(error: errno)
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
            throw ReaderError.GenericError(error: errno)
        }
        var bytes = [Byte]()
        for i in 0..<size {
            bytes.append(buffer[i])
        }
        buffer.deallocate(capacity: byteCount)
        return Data(bytes)
    }

}
