#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
    let syscall_close = Darwin.close
#elseif os(Linux)
    import Glibc
    let syscall_close = Glibc.close
#endif

public struct PosixFileMode: OptionSet {
    typealias RawRepresentable = Int32
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    static let readOnly = PosixFileMode(rawValue: O_RDONLY)
    static let writeOnly = PosixFileMode(rawValue: O_WRONLY)
    static let readWrite = PosixFileMode(rawValue: O_RDWR)
    
    // TODO: Add more constants
    static let append = PosixFileMode(rawValue: O_APPEND)
    static let create = PosixFileMode(rawValue: O_CREAT)
    static let exclude = PosixFileMode(rawValue: O_EXCL)
    static let truncate = PosixFileMode(rawValue: O_TRUNC)
}

public struct PosixFilePermission: OptionSet {
    typealias RawRepresentable = mode_t
    
    public let rawValue: mode_t
    
    public init(rawValue: mode_t) {
        self.rawValue = rawValue
    }
    
    static let rwxUser = PosixFilePermission(rawValue: S_IRWXU)
    static let rUser = PosixFilePermission(rawValue: S_IRUSR)
    static let wUser = PosixFilePermission(rawValue: S_IWUSR)
    static let xUser = PosixFilePermission(rawValue: S_IXUSR)
    static let rwxGroup = PosixFilePermission(rawValue: S_IRWXG)
    static let rGroup = PosixFilePermission(rawValue: S_IRGRP)
    static let wGroup = PosixFilePermission(rawValue: S_IWGRP)
    static let xGroup = PosixFilePermission(rawValue: S_IXGRP)
    static let rwxOther = PosixFilePermission(rawValue: S_IRWXO)
    static let rOther = PosixFilePermission(rawValue: S_IROTH)
    static let wOther = PosixFilePermission(rawValue: S_IWOTH)
    static let xOther = PosixFilePermission(rawValue: S_IXOTH)
    
    static let of644: PosixFilePermission = [.rUser, .wUser, .rGroup, .rOther]
}

public class PosixFile: File {
    
    public var rawDescriptor: Int32 = 0
    public var closed: Bool
    
    init?(name: String, flags: PosixFileMode, mode: PosixFilePermission = .of644) {
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
