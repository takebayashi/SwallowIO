import C7

public protocol SocketServer {
    associatedtype SocketType: Socket
    
    var socket: SocketType { get }
    
    init?(socket: SocketType, address: SocketType.AddressType)
    func run(handler: (Stream) throws -> ()) throws
}

public protocol TCPServer: SocketServer {
    associatedtype AcceptorType: SocketAcceptor
    
    var acceptor: AcceptorType { get }
}

public extension TCPServer where AcceptorType.SocketType == SocketType {
    public func run(handler: (Stream) throws -> ()) throws {
        defer {
            socket.forceClose()
        }
        while true {
            let (clientSocket, clientAddress) = try acceptor.accept()
            defer {
                clientSocket.forceClose()
            }
            try handler(clientSocket)
        }
    }
}

public class BlockingTCPServer: TCPServer {
    public typealias SocketType = PosixSocket
    public typealias AcceptorType = BlockingSocketAcceptor

    public let socket: SocketType
    public let acceptor: BlockingSocketAcceptor
    
    public required init?(socket: SocketType, address: SocketType.AddressType) {
        self.socket = socket
        do {
            self.acceptor = try BlockingSocketAcceptor(socket: socket)
            try socket.bindAddress(address: address)
            try socket.listenConnection(backlog: 10)
        } catch {
            return nil
        }
    }
}
