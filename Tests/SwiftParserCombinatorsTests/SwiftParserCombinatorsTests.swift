import XCTest
@testable import SwiftParserCombinators

extension String {
    init(tuple: (Character, Character)) {
        self.init([tuple.0, tuple.1])
    }
}

class SwiftParserCombinatorsTests: XCTestCase {

    func expectSuccess(parser: Parser<String, StringReader>, input: String, expected: String) {
        let reader = StringReader(string: input)
        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, expected)
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    func expectFailure(parser: Parser<String, StringReader>, input: String) {
        let reader = StringReader(string: input)
        let result = parser.parse(reader)
        switch result {
        case .success:
            XCTFail("\(result) is successful")
        case .failure:
            break
        }
    }

    func testMap() {
        let extractedExpr: Parser<String, StringReader> = 
            char(Character("a"))
                .map { String($0).uppercased() }
        expectSuccess(parser: extractedExpr,
                      input: "a",
                      expected: "A")
    }

    func testSeq() {
        let parser: Parser<String, StringReader> =
            (char(Character("a")) ~ char(Character("b")))
                .map(String.init)

        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "ab")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "ab")
        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "b")
        expectFailure(parser: parser,
                      input: "ba")
    }

    func testSeqIgnoreLeft() {
        let parser: Parser<String, StringReader> =
            (char(Character("a")) ~> char(Character("b")))
                .map(String.init)

        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "b")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "b")
        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "b")
    }

    func testSeqIgnoreRight() {
        let parser: Parser<String, StringReader> =
            (char(Character("a")) <~ char(Character("b")))
                .map(String.init)

        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "a")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "a")
        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "b")
    }

    func testOr() {
        let parser: Parser<String, StringReader> =
            (char(Character("a")) | char(Character("b")))
                .map(String.init)

        expectSuccess(parser: parser,
                      input: "a",
                      expected: "a")
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "a")
        expectSuccess(parser: parser,
                      input: "b",
                      expected: "b")
        expectSuccess(parser: parser,
                      input: "ba",
                      expected: "b")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "a")
    }

    func testOrFirstSuccess() {
        let parser: Parser<String, StringReader> =
            char(Character("a")).map(String.init)
            | (char(Character("a")) ~ char(Character("b")))
                .map(String.init)

        expectSuccess(parser: parser,
                      input: "a",
                      expected: "a")
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "a")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "a")
    }

    static var allTests = [
        ("testMap", testMap),
        ("testSeq", testSeq),
        ("testSeqIgnoreLeft", testSeqIgnoreLeft),
        ("testSeqIgnoreRight", testSeqIgnoreRight),
        ("testOr", testOr),
        ("testOrFirstSuccess", testOrFirstSuccess)
    ]
}
