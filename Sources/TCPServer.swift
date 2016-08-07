public protocol TCPServer {
    associatedtype SocketType: Socket
}

public class BlockingTCPServer: TCPServer {
    public typealias SocketType = PosixSocket

    let socket: SocketType
    let acceptor: BlockingSocketAcceptor

    public init?(socket: SocketType, address: SocketAddress) {
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
