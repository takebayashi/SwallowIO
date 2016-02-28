#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public class TCP {

    public static func bind(port: UInt16) -> Socket? {
        guard let socket = Socket() else {
            return nil
        }
        var addr = SocketAddress(port: port).underlying
        socket.bindAddress(&addr, length: socklen_t(UInt8(sizeof(sockaddr_in))))
        return socket
    }

}
