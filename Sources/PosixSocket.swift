#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public class PosixSocket: Socket {
    public typealias AddressType = PosixSocketAddress
    
    public enum AddressFamily {
        case Inet
        case Inet6
        case Unix
        
        var rawValue: Int32 {
            get {
                switch self {
                case (.Inet):
                    return AF_INET
                case (.Inet6):
                    return AF_INET6
                case (.Unix):
                    return AF_UNIX
                }
            }
        }
    }
    
    public enum Semantics {
        case Stream
        
        var rawValue: Int32 {
            get {
                switch self {
                case (.Stream):
                    #if os(OSX)
                        return SOCK_STREAM
                    #else
                        return Int32(SOCK_STREAM.rawValue)
                    #endif
                }
            }
        }
    }
    
    public let rawDescriptor: Int32
    
    public private(set) var closed: Bool = false
    
    public init?(domain: AddressFamily = .Inet, type: Semantics = .Stream, proto: Int32 = 0) {
        rawDescriptor = socket(domain.rawValue, type.rawValue, proto)
        if rawDescriptor <= 0 {
            return nil
        }
    }
    
    public init(rawDescriptor: Int32) {
        self.rawDescriptor = rawDescriptor
    }
    
    public func bindAddress(address: PosixSocketAddress) throws {
        var mutable = address
        let result = mutable.withUnsafeMutablePointer { pointer, length in
            return bind(self.rawDescriptor, pointer, length)
        }
        if result != 0 {
            throw IOError.GenericError(code: errno)
        }
    }
    
    public func listenConnection(backlog: Int32) throws {
        let result = listen(rawDescriptor, backlog)
        if result != 0 {
            throw IOError.GenericError(code: errno)
        }
    }
    
    public func acceptClient() throws -> (PosixSocket, PosixSocketAddress) {
        var addr = sockaddr_in()
        var addrlen = socklen_t(MemoryLayout<socklen_t>.size)
        let wrapper = { (addrPtr: UnsafeMutableRawPointer, addrlenPtr: UnsafeMutablePointer<socklen_t>) -> Int32 in
            return accept(self.rawDescriptor, UnsafeMutablePointer<sockaddr>(OpaquePointer(addrPtr)), addrlenPtr)
        }
        let fd = wrapper(&addr, &addrlen)
        if fd < 0 {
            throw IOError.GenericError(code: errno)
        }
        return (PosixSocket(rawDescriptor: fd), PosixSocketAddress(rawValue: addr, length: addrlen))
    }
    
    
    public func close() throws {
        var result: Int32
        #if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
            result = Darwin.close(rawDescriptor)
        #else
            result = Glibc.close(rawDescriptor)
        #endif
        if result != 0 {
            throw IOError.GenericError(code: errno)
        }
        closed = true
    }
    
    public func setOption(option: Int32, value: Int32) {
        var val = value
        setsockopt(rawDescriptor, SOL_SOCKET, option, &val, socklen_t(MemoryLayout<Int32>.size))
    }
}
