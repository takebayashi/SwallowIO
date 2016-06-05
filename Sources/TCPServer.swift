public class TCPServer {

    let socket: Socket

    public init?(socket: Socket, address: SocketAddress) {
        self.socket = socket
        do {
            try socket.bindAddress(address: address)
            try socket.listenConnection(backlog: 10)
        } catch {
            return nil
        }
    }

    public func acceptClient(handler: (Socket, SocketAddress) -> Bool) throws {
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

    public func close() {
        socket.close()
    }

}
