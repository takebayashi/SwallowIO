#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public protocol FileDescriptor {

		init(rawDescriptor: Int32)
    
    var rawDescriptor: Int32 { get }

}
