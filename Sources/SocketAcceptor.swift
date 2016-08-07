public protocol SocketAcceptor {
    associatedtype SocketType: Socket
    
    func accept(socket: SocketType, handler: (SocketType, SocketType.AddressType) -> ()) throws
}

public class BlockingSocketAcceptor: SocketAcceptor {
    public typealias SocketType = PosixSocket
    
    public func accept(socket: PosixSocket, handler: (SocketType, SocketType.AddressType) -> ()) throws {
        let (clientSocket, clientAddress) = try socket.acceptClient()
        handler(clientSocket, clientAddress)
        try clientSocket.close()
    }
}
