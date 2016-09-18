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

public protocol PosixSocketAddressConvertible {
    mutating func withUnsafeMutablePointer<R>(_ proc: @escaping (UnsafeMutablePointer<sockaddr>, socklen_t) -> R) -> R
}

extension sockaddr_in: PosixSocketAddressConvertible {
    public mutating func withUnsafeMutablePointer<R>(_ proc: @escaping (UnsafeMutablePointer<sockaddr>, socklen_t) -> R) -> R {
        let lambda = { (pointer: UnsafeMutableRawPointer, length: socklen_t) in
            return proc(UnsafeMutablePointer<sockaddr>(OpaquePointer(pointer)), length)
        }
        return lambda(&self, socklen_t(MemoryLayout<sockaddr_in>.size))
    }
}

public struct PosixSocketAddress: SocketAddress {
    
    var rawValue: PosixSocketAddressConvertible
    var length: socklen_t
    
    mutating func withUnsafeMutablePointer<R>(proc: @escaping (UnsafeMutablePointer<sockaddr>, socklen_t) -> R) -> R {
        return rawValue.withUnsafeMutablePointer(proc)
    }
    
    static func htons(value: CUnsignedShort) -> CUnsignedShort {
        return value.bigEndian
    }
    
    public init(port: UInt16, addressFamily: PosixSocket.AddressFamily = .Inet) {
        switch addressFamily {
        case .Inet:
            #if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
                rawValue = sockaddr_in(
                    sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size),
                    sin_family: sa_family_t(addressFamily.rawValue),
                    sin_port: PosixSocketAddress.htons(value: port),
                    sin_addr: in_addr(s_addr: in_addr_t(0)),
                    sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
                )
            #else
                rawValue = sockaddr_in(
                    sin_family: sa_family_t(addressFamily.rawValue),
                    sin_port: PosixSocketAddress.htons(value: port),
                    sin_addr: in_addr(s_addr: in_addr_t(0)),
                    sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
                )
            #endif
            length = socklen_t(MemoryLayout<sockaddr_in>.size)
        default:
            fatalError("not implemented")
        }
    }
    
    public init(rawValue: sockaddr_in, length: socklen_t) {
        self.rawValue = rawValue
        self.length = length
    }
    
}
