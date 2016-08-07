typealias SocketAcceptorHandler = (Socket, SocketAddress) -> ()

protocol SocketAcceptor {
    func accept(socket: Socket, handler: SocketAcceptorHandler) throws
}

class BlockingSocketAcceptor: SocketAcceptor {
    func accept(socket: Socket, handler: SocketAcceptorHandler) throws {
        let (clientSocket, clientAddress) = try socket.acceptClient()
        handler(clientSocket, clientAddress)
        try clientSocket.close()
    }
}
