#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif
import C7

public protocol FileDescriptor: Stream, Closable {
    var rawDescriptor: Int32 { get }
}
