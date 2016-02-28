#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public class TCP {

    public static func bind(address: SocketAddress) -> Socket? {
        guard let socket = Socket() else {
            return nil
        }
        socket.bindAddress(address)
        return socket
    }

}
