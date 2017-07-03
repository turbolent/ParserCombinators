import XCTest
@testable import SwiftParserCombinators

extension String {
    init(tuple: (Character, Character)) {
        self.init([tuple.0, tuple.1])
    }
}

class SwiftParserCombinatorsTests: XCTestCase {

    func testMap() {
        let parser: Parser<String, StringReader> =
            char(Character("a")).map { String($0).uppercased() }

        let reader = StringReader(string: "a")

        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, "A")
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    func testSeq() {
        let parser: Parser<(Character, Character), StringReader> =
            char(Character("a")) ~ char(Character("b"))

        let reader = StringReader(string: "ab")

        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertTrue(value == (Character("a"), Character("b")))
        case .failure:
            XCTFail("\(result) is not successful")
        }

    }

    func testSeqIgnoreLeft() {
        let parser: Parser<Character, StringReader> =
            char(Character("a")) ~> char(Character("b"))

        let reader = StringReader(string: "ab")

        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, Character("b"))
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    func testSeqIgnoreRight() {
        let parser: Parser<Character, StringReader> =
            char(Character("a")) <~ char(Character("b"))

        let reader = StringReader(string: "ab")

        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, Character("a"))
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    func testOrFirst() {
        let parser: Parser<Character, StringReader> =
            char(Character("a")) | char(Character("b"))

        let reader = StringReader(string: "a")

        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, Character("a"))
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    func testOrAlternative() {
        let parser: Parser<Character, StringReader> =
            char(Character("a")) | char(Character("b"))

        let reader = StringReader(string: "b")

        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, Character("b"))
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    func testOrFirstSuccess() {
        let parser: Parser<String, StringReader> =
            char(Character("a")).map(String.init)
            | (char(Character("a")) ~ char(Character("b")))
                .map(String.init)

        let reader = StringReader(string: "ab")

        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, "a")
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    static var allTests = [
        ("testMap", testMap),
        ("testSeq", testSeq),
        ("testSeqIgnoreLeft", testSeqIgnoreLeft),
        ("testSeqIgnoreRight", testSeqIgnoreRight),
        ("testOrFirst", testOrFirst),
        ("testOrAlternative", testOrAlternative),
        ("testOrFirstSuccess", testOrFirstSuccess)
    ]
}
