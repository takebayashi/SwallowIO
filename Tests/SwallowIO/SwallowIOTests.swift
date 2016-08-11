import XCTest
import C7
@testable import SwallowIO

class SwallowIOTests: XCTestCase {
    func testFileRead() {
        let filename = "Tests/SwallowIO/Fixtures/HelloSwift.txt"
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


    static var allTests : [(String, (SwallowIOTests) -> () throws -> Void)] {
        return [
            ("testFileRead", testFileRead),
        ]
    }
}
