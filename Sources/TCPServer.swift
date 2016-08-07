public class TCPServer {

    let socket: Socket
    let acceptor: SocketAcceptor

    public init?(socket: Socket, address: SocketAddress) {
        self.socket = socket
        self.acceptor = BlockingSocketAcceptor()
        do {
            try socket.bindAddress(address: address)
            try socket.listenConnection(backlog: 10)
        } catch {
            return nil
        }
    }

    public func acceptClient(handler: (Socket, SocketAddress) -> ()) throws {
        while true {
            try self.acceptor.accept(socket: self.socket, handler: handler)
        }
    }

    public func close() throws {
        try socket.close()
    }

}
