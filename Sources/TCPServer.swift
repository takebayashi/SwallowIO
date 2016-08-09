public protocol TCPServer {
    associatedtype SocketType: Socket
}

public class BlockingTCPServer: TCPServer {
    public typealias SocketType = PosixSocket

    let socket: SocketType
    let acceptor: BlockingSocketAcceptor

    public init?(socket: SocketType, address: SocketType.AddressType) throws {
        self.socket = socket
        self.acceptor = try BlockingSocketAcceptor(socket: socket)
        do {
            try socket.bindAddress(address: address)
            try socket.listenConnection(backlog: 10)
        } catch {
            return nil
        }
    }

    public func acceptClient(handler: (SocketType, SocketType.AddressType) throws -> ()) throws {
        while true {
            let (clientSocket, clientAddress) = try acceptor.accept()
            defer {
                do {
                    try clientSocket.close()
                }
                catch {
                    // ignore
                }
            }
            try handler(clientSocket, clientAddress)
        }
    }

    public func close() throws {
        try socket.close()
    }

}
