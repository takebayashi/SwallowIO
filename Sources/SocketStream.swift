import C7

#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
    let syscall_send = Darwin.send
#elseif os(Linux)
    import Glibc
    let syscall_send = Glibc.send
#endif

extension FileDescriptor {
    
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

}
