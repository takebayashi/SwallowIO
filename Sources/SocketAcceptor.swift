import C7

public protocol SocketAcceptor {
    associatedtype SocketType: Socket
    
    init(socket: SocketType) throws
    func accept() throws -> (SocketType, SocketType.AddressType)
}

public final class BlockingSocketAcceptor: SocketAcceptor {
    public typealias SocketType = PosixSocket
    
    var socket: SocketType
    
    public init(socket: SocketType) throws {
        self.socket = socket
    }
    
    public func accept() throws -> (SocketType, SocketType.AddressType) {
        return try socket.acceptClient()
    }
}
