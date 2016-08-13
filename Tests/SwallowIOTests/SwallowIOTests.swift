import XCTest
import C7
@testable import SwallowIO
#if os(OSX) || os(tvOS) || os(watchOS) || os(iOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

class SwallowIOTests: XCTestCase {
    func testFileRead() {
        let filename = "Tests/SwallowIOTests/Fixtures/HelloSwift.txt"
        guard let file = PosixFile(name: filename, flags: FileOperationFlag.readOnly) else {
            XCTFail("failed to open " + filename)
            return
        }
        do {
            let data = try file.receive(upTo: 64, timingOut: 30)
            let expected = C7.Data("Hello, Swift" + "\n")
            XCTAssertEqual(data, expected)
            try file.close()
        }
        catch IOError.GenericError(let code) {
            XCTFail("operation failed: " + code.description)
        }
        catch {
            XCTFail("operation failed: unknown error")
        }
    }

    func testFileWrite() {
        let filename = "SwiftOutput.txt"
        
        // write to file
        guard let outFile = PosixFile(name: filename, flags: [.writeOnly, .create, .truncate]) else {
            XCTFail("failed to open " + filename)
            return
        }
        do {
            try outFile.send(C7.Data("Hello, World!"))
            try outFile.close()
        }
        catch IOError.GenericError(let code) {
            XCTFail("operation failed: " + String(cString: strerror(code)))
        }
        catch {
            XCTFail("operation failed: unknown error")
        }
        
        // read from file
        guard let inFile = PosixFile(name: filename, flags: [.readOnly]) else {
            XCTFail("failed to open " + filename)
            return
        }
        do {
            let data = try inFile.receive(upTo: 64)
            let expected = C7.Data("Hello, World!")
            XCTAssertEqual(data, expected)
            try inFile.close()
        }
        catch IOError.GenericError(let code) {
            XCTFail("operation failed: " + String(cString: strerror(code)))
        }
        catch {
            XCTFail("operation failed: unknown error")
        }
        
        // cleanup
        unlink(filename)
    }

    static var allTests : [(String, (SwallowIOTests) -> () throws -> Void)] {
        return [
            ("testFileRead", testFileRead),
        ]
    }
}
