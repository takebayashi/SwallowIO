#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

extension CUnsignedShort {
    fileprivate func htons() -> CUnsignedShort {
        return self.bigEndian
    }
}

public protocol PosixSocketAddressConvertible: SocketAddress {
    mutating func withUnsafeMutablePointer<R>(_ proc: @escaping (UnsafeMutablePointer<sockaddr>, socklen_t) -> R) -> R
}

extension PosixSocketAddressConvertible {
    public mutating func withUnsafeMutablePointer<R>(_ proc: @escaping (UnsafeMutablePointer<sockaddr>, socklen_t) -> R) -> R {
        let lambda = { (pointer: UnsafeMutableRawPointer, length: socklen_t) in
            return proc(UnsafeMutablePointer<sockaddr>(OpaquePointer(pointer)), length)
        }
        return lambda(&self, socklen_t(MemoryLayout<Self>.size))
    }
}

public struct PosixSocketAddress: SocketAddress {
    var rawValue: PosixSocketAddressConvertible
    var length: socklen_t
    
    public init(rawValue: PosixSocketAddressConvertible, length: socklen_t) {
        self.rawValue = rawValue
        self.length = length
    }
    
    mutating func withUnsafeMutablePointer<R>(proc: @escaping (UnsafeMutablePointer<sockaddr>, socklen_t) -> R) -> R {
        return rawValue.withUnsafeMutablePointer(proc)
    }
}

extension sockaddr_in: PosixSocketAddressConvertible {}

extension PosixSocketAddress {
    public init(_ address: sockaddr_in) {
        self.rawValue = address
        self.length = socklen_t(MemoryLayout<sockaddr_in>.size)
    }

    public init(address: UInt32, port: UInt16) {
        var addr = sockaddr_in()
        #if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
            addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        #endif
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.htons()
        addr.sin_addr = in_addr(s_addr: in_addr_t(address))
        self.init(addr)
    }
}

extension sockaddr_un: PosixSocketAddressConvertible {}

extension PosixSocketAddress {
    public init(_ address: sockaddr_un) {
        self.rawValue = address
        self.length = socklen_t(MemoryLayout<sockaddr_un>.size)
    }

    public init(path: String) {
        var addr = sockaddr_un()
        #if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
            addr.sun_len = UInt8(MemoryLayout<sockaddr_un>.size)
        #endif
        addr.sun_family = sa_family_t(AF_UNIX)
        path.withCString { string -> Void in
            strcpy(&addr.sun_path.0, string)
        }
        self.init(addr)
    }
}
