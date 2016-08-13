#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
    let syscall_close = Darwin.close
#elseif os(Linux)
    import Glibc
    let syscall_close = Glibc.close
#endif
import C7

public protocol FileDescriptor: Stream, Closable {
    var rawDescriptor: Int32 { get }
}

public extension FileDescriptor {
    @discardableResult
    public func forceClose() -> Bool {
        do {
            try self.close()
            return true
        }
        catch {
            return false
        }
    }
}

public protocol File: FileDescriptor {
}

public struct FileOperationFlag: OptionSet {
    typealias RawRepresentable = Int32
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    static let readOnly = FileOperationFlag(rawValue: O_RDONLY)
    static let writeOnly = FileOperationFlag(rawValue: O_WRONLY)
    static let readWrite = FileOperationFlag(rawValue: O_RDWR)
    
    // TODO: Add more constants
    static let append = FileOperationFlag(rawValue: O_APPEND)
    static let create = FileOperationFlag(rawValue: O_CREAT)
    static let exclude = FileOperationFlag(rawValue: O_EXCL)
    static let truncate = FileOperationFlag(rawValue: O_TRUNC)
}

public struct FilePermissionFlag: OptionSet {
    typealias RawRepresentable = mode_t
    
    public let rawValue: mode_t
    
    public init(rawValue: mode_t) {
        self.rawValue = rawValue
    }
    
    static let rwxUser = FilePermissionFlag(rawValue: S_IRWXU)
    static let rUser = FilePermissionFlag(rawValue: S_IRUSR)
    static let wUser = FilePermissionFlag(rawValue: S_IWUSR)
    static let xUser = FilePermissionFlag(rawValue: S_IXUSR)
    static let rwxGroup = FilePermissionFlag(rawValue: S_IRWXG)
    static let rGroup = FilePermissionFlag(rawValue: S_IRGRP)
    static let wGroup = FilePermissionFlag(rawValue: S_IWGRP)
    static let xGroup = FilePermissionFlag(rawValue: S_IXGRP)
    static let rwxOther = FilePermissionFlag(rawValue: S_IRWXO)
    static let rOther = FilePermissionFlag(rawValue: S_IROTH)
    static let wOther = FilePermissionFlag(rawValue: S_IWOTH)
    static let xOther = FilePermissionFlag(rawValue: S_IXOTH)
    
    static let of644: FilePermissionFlag = [.rUser, .wUser, .rGroup, .rOther]
}

public class PosixFile: File {
    
    public var rawDescriptor: Int32 = 0
    public var closed: Bool
    
    init?(name: String, flags: FileOperationFlag, mode: FilePermissionFlag = .of644) {
        self.rawDescriptor = name.withCString { (string) -> Int32 in
            return open(string, flags.rawValue, mode.rawValue)
        }
        if self.rawDescriptor < 0 {
            return nil
        }
        self.closed = false
    }

    public func close() throws {
        let result = syscall_close(rawDescriptor)
        if result != 0 {
            throw IOError.GenericError(code: errno)
        }
        closed = true
    }
}
