#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public protocol SocketAddress  {
}

public protocol Socket: FileDescriptor {
    associatedtype AddressType: SocketAddress
    
    func bindAddress(address: AddressType) throws
    func listenConnection(backlog: Int32) throws
    func close() throws
}
