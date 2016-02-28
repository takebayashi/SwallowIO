#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public class TCPServer {

    let socket: Socket

    public init(socket: Socket) {
        self.socket = socket
    }

    public func bindAndListen(address: SocketAddress, handler: (Socket, SocketAddress) -> Bool) throws {
        try socket.bindAddress(address)
        try socket.listenConnection(10)
        defer {
            socket.close()
        }
        while true {
            let (clientSocket, clientAddress) = try socket.acceptClient()
            defer {
                clientSocket.close()
            }
            if !handler(clientSocket, clientAddress) {
                break
            }
        }
    }

}
