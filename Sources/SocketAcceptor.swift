public typealias SocketAcceptorHandler = (Socket, SocketAddress) -> ()

public protocol SocketAcceptor {
    associatedtype SocketType: Socket
    
    func accept(socket: SocketType, handler: SocketAcceptorHandler) throws
}

public class BlockingSocketAcceptor: SocketAcceptor {
    public typealias SocketType = PosixSocket
    
    public func accept(socket: PosixSocket, handler: SocketAcceptorHandler) throws {
        let (clientSocket, clientAddress) = try socket.acceptClient()
        handler(clientSocket, clientAddress)
        try clientSocket.close()
    }
}
