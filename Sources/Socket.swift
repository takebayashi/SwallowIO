#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public struct Socket: FileDescriptor {

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

    public enum Type {
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

    public init?(domain: AddressFamily = .Inet, type: Type = .Stream, proto: Int32 = 0) {
        rawDescriptor = socket(domain.rawValue, type.rawValue, proto)
        if rawDescriptor <= 0 {
            return nil
        }
    }

    public init(rawDescriptor: Int32) {
        self.rawDescriptor = rawDescriptor
    }

    public func bindAddress(address: SocketAddress) -> Bool {
        var mutable = address
        return mutable.withUnsafeMutablePointer { pointer in
            return bind(self.rawDescriptor, pointer, socklen_t(UInt8(sizeof(sockaddr_in)))) == 0
        }
    }

    public func setOption(option: Int32, value: Int32) {
        var val = value
        setsockopt(rawDescriptor, SOL_SOCKET, option, &val, socklen_t(sizeof(Int32)))
    }
}

public struct SocketAddress {

    var rawValue: sockaddr_in

    mutating func withUnsafeMutablePointer<R>(proc: (UnsafeMutablePointer<sockaddr>) -> R) -> R {
        let wrapper = { (p: UnsafeMutablePointer<()>) -> R in
            return proc(UnsafeMutablePointer<sockaddr>(p))
        }
        return wrapper(&rawValue)
    }

    static func htons(value: CUnsignedShort) -> CUnsignedShort {
        return value.bigEndian
    }

    public init(port: UInt16, addressFamily: Socket.AddressFamily = .Inet) {
#if os(OSX)
        rawValue = sockaddr_in(
            sin_len: __uint8_t(sizeof(sockaddr_in)),
            sin_family: sa_family_t(addressFamily.rawValue),
            sin_port: SocketAddress.htons(port),
            sin_addr: in_addr(s_addr: in_addr_t(0)),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
#else
        rawValue = sockaddr_in(
            sin_family: sa_family_t(addressFamily.rawValue),
            sin_port: SocketAddress.htons(port),
            sin_addr: in_addr(s_addr: in_addr_t(0)),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
#endif
    }

}
