import XCTest
@testable import SwallowIO

class SwallowIOTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(SwallowIO().text, "Hello, World!")
    }


    static var allTests : [(String, (SwallowIOTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
