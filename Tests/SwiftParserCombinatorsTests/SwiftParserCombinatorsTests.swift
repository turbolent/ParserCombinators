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

    func expectSuccess(parser: Parser<String?, StringReader>, input: String, expected: String?) {
        let reader = StringReader(string: input)
        let result = parser.parse(reader)
        switch result {
        case .success(let value, _):
            XCTAssertEqual(value, expected)
        case .failure:
            XCTFail("\(result) is not successful")
        }
    }

    func expectSuccess(parser: Parser<[String], StringReader>, input: String, expected: [String]) {
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

    func expectFailure(parser: Parser<String?, StringReader>, input: String) {
        let reader = StringReader(string: input)
        let result = parser.parse(reader)
        switch result {
        case .success:
            XCTFail("\(result) is successful")
        case .failure:
            break
        }
    }

    func expectFailure(parser: Parser<[String], StringReader>, input: String) {
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

    func testOpt() {
        let parser: Parser<String?, StringReader> =
            char(Character("a")).map(String.init).opt()

        expectSuccess(parser: parser,
                      input: "a",
                      expected: "a")

        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "a")

        expectSuccess(parser: parser,
                      input: "",
                      expected: nil)

        // NOTE: successful, as "b" is remaining input
        expectSuccess(parser: parser,
                      input: "b",
                      expected: nil)
    }

    func testRepNoMinNoMax() {
        let parser: Parser<[String], StringReader> =
            char(Character("a"))
                .map(String.init)
                .rep()

        expectSuccess(parser: parser,
                      input: "",
                      expected: [])
        expectSuccess(parser: parser,
                      input: "a",
                      expected: ["a"])
        expectSuccess(parser: parser,
                      input: "aa",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: ["a"])
        // NOTE: successful, as "b" is remaining input
        expectSuccess(parser: parser,
                      input: "b",
                      expected: [])
    }

    func testRepMinNoMax() {
        let parser: Parser<[String], StringReader> =
            char(Character("a"))
                .map(String.init)
                .rep(min: 2)

        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectSuccess(parser: parser,
                      input: "aa",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "aab",
                      expected: ["a", "a"])
        expectFailure(parser: parser,
                      input: "ab")
        expectSuccess(parser: parser,
                      input: "aaa",
                      expected: ["a", "a", "a"])
    }

    func testRepMinMax() {
        let parser: Parser<[String], StringReader> =
            char(Character("a"))
                .map(String.init)
                .rep(min: 2, max: 4)

        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectSuccess(parser: parser,
                      input: "aa",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "aaa",
                      expected: ["a", "a", "a"])
        expectSuccess(parser: parser,
                      input: "aaaa",
                      expected: ["a", "a", "a", "a"])
        expectSuccess(parser: parser,
                      input: "aaaaa",
                      expected: ["a", "a", "a", "a"])
        expectSuccess(parser: parser,
                      input: "aab",
                      expected: ["a", "a"])
        expectFailure(parser: parser,
                      input: "ab")
    }

    static var allTests = [
        ("testMap", testMap),
        ("testSeq", testSeq),
        ("testSeqIgnoreLeft", testSeqIgnoreLeft),
        ("testSeqIgnoreRight", testSeqIgnoreRight),
        ("testOr", testOr),
        ("testOrFirstSuccess", testOrFirstSuccess),
        ("testOpt", testOpt),
        ("testRepNoMinNoMax", testRepNoMinNoMax),
        ("testRepMinNoMax", testRepMinNoMax),
        ("testRepMinMax", testRepMinMax)
    ]
}
