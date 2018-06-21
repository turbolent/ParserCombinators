import XCTest
import SwiftParserCombinators

extension Parser where T == [Character] {
    var stringParser: Parser<String, Element> {
        return self ^^ { String($0) }
    }
}

class SwiftParserCombinatorsTests: XCTestCase {

    func testAccept() {
        let parser = char("a")

        expectSuccess(parser: parser,
                      input: "a",
                      expected: Character("a"))
        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "b")
        expectFailure(parser: parser,
                      input: " a")
    }

    func testLiteral() {
        let parser = literal("test")

        expectSuccess(parser: parser,
                      input: "test",
                      expected: "test")
        expectSuccess(parser: parser,
                      input: "testing",
                      expected: "test")
        expectFailure(parser: parser,
                      input: "atest")
        expectFailure(parser: parser,
                      input: " test")
    }

    func testMap() {
        let parser =
            char("a") ^^ { String($0).uppercased() }

        expectSuccess(parser: parser,
                      input: "a",
                      expected: "A")
    }

    func testMapValue() {
        let parser =
            char("a") ^^^ "XXX"

        expectSuccess(parser: parser,
                      input: "a",
                      expected: "XXX")
    }

    func testSeq() {
        let parser =
            (char("a") ~ char("b")).stringParser

        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "ab")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "ab")
        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "b")
        expectFailure(parser: parser,
                      input: "ba")
    }

    func testSeq3() {
        let parser =
            (char("a") ~ char("b") ~ char("c")).stringParser

        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "abc")
        expectSuccess(parser: parser,
                      input: "abcd",
                      expected: "abc")
        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "ab")
        expectFailure(parser: parser,
                      input: "b")
        expectFailure(parser: parser,
                      input: "cba")
    }

    func testSeq4() {
        let parser =
            (char("a") ~ char("b") ~ char("c") ~ char("d")).stringParser

        expectSuccess(parser: parser,
                      input: "abcd",
                      expected: "abcd")
        expectSuccess(parser: parser,
                      input: "abcde",
                      expected: "abcd")
        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "ab")
        expectFailure(parser: parser,
                      input: "abc")
        expectFailure(parser: parser,
                      input: "b")
        expectFailure(parser: parser,
                      input: "dcba")
    }

    func testSeq5() {
        let parser =
            (char("a") ~ char("b") ~ char("c") ~ char("d") ~ char("e")).stringParser

        expectSuccess(parser: parser,
                      input: "abcde",
                      expected: "abcde")
        expectSuccess(parser: parser,
                      input: "abcdef",
                      expected: "abcde")
        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "ab")
        expectFailure(parser: parser,
                      input: "abc")
        expectFailure(parser: parser,
                      input: "abcd")
        expectFailure(parser: parser,
                      input: "b")
        expectFailure(parser: parser,
                      input: "edcba")
    }


    func testSeqIgnoreLeft() {
        let parser =
            (char("a") ~> char("b")) ^^ String.init

        expectFailure(parser: parser,
                      input: "")
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
        let parser =
            (char("a") <~ char("b")) ^^ String.init

        expectFailure(parser: parser,
                      input: "")
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
        let parser =
            (char("a") || char("b")) ^^ String.init

        expectFailure(parser: parser,
                      input: "")
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

    func testCommitOr() {
        let parser =
            ((char("a") ~ commit(char("b")))
                || (char("a") ~ char("c"))).stringParser

        expectFailure(parser: parser,
                      input: "")
        expectError(parser: parser,
                    input: "a")
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "ab")
        expectError(parser: parser,
                    input: "ac")
    }

    func testOrFirstSuccess() {
        let parser =
            (char("a") ^^ String.init)
                || ((char("a") ~ char("b")).stringParser)

        expectFailure(parser: parser,
                      input: "")
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

    func testOrLonger() {
        let parser =
            (char("a") ^^ String.init)
                ||| ((char("a") ~ char("b")).stringParser)

        expectFailure(parser: parser,
                      input: "")
        expectSuccess(parser: parser,
                      input: "a",
                      expected: "a")
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "ab")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "ab")
    }

    func testCommitOrLonger() {
        let parser =
            (commit(char("a")) ^^ String.init)
                ||| ((char("a") ~ char("b")).stringParser)

        expectError(parser: parser,
                    input: "")
        expectError(parser: parser,
                    input: "b")
        expectSuccess(parser: parser,
                      input: "a",
                      expected: "a")
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: "ab")
        expectSuccess(parser: parser,
                      input: "abc",
                      expected: "ab")
    }

    func testOpt() {
        let parser =
            (char("a") ^^ String.init).opt()

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
        let parser =
            (char("a") ^^ String.init).rep()

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
        let parser =
            (char("a") ^^ String.init).rep(min: 2)

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
        let parser =
            (char("a") ^^ String.init).rep(min: 2, max: 4)

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

    func testRepZeroMax() {
        let parser =
            char("a").rep(max: 0)

        expectSuccess(parser: parser,
                      input: "",
                      expected: [])
        expectSuccess(parser: parser,
                      input: "a",
                      expected: [])
        expectSuccess(parser: parser,
                      input: "aa",
                      expected: [])
    }

    func testRepError() {
        let parser =
            commit(char("a") ^^ String.init).rep(min: 1)

        expectSuccess(parser: parser,
                      input: "a",
                      expected: ["a"])
        expectSuccess(parser: parser,
                      input: "aa",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: ["a"])
        expectSuccess(parser: parser,
                      input: "aba",
                      expected: ["a"])
        expectError(parser: parser,
                    input: "")
        expectError(parser: parser,
                    input: "b")
    }

    func testRepSepNoMinNoMax() {
        let parser =
            char("a").rep(separator: char(","))

        expectSuccess(parser: parser,
                      input: "",
                      expected: [])
        expectSuccess(parser: parser,
                      input: "a",
                      expected: ["a"])
        expectSuccess(parser: parser,
                      input: "a,a",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "ab",
                      expected: ["a"])
        expectSuccess(parser: parser,
                      input: "a,ab",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "a,a,b",
                      expected: ["a", "a"])
        // NOTE: successful, as "b" is remaining input
        expectSuccess(parser: parser,
                      input: "b",
                      expected: [])
    }

    func testRepSepMinNoMax() {
        let parser =
            (char("a") ^^ String.init)
                .rep(separator: char(","),
                     min: 2)

        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectSuccess(parser: parser,
                      input: "a,a",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "a,ab",
                      expected: ["a", "a"])
        expectFailure(parser: parser,
                      input: "ab")
        expectSuccess(parser: parser,
                      input: "a,a,a",
                      expected: ["a", "a", "a"])
    }

    func testRepSepMinMax() {
        let parser =
            (char("a") ^^ String.init)
                .rep(separator: char(","),
                     min: 2, max: 4)

        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "a")
        expectSuccess(parser: parser,
                      input: "a,a",
                      expected: ["a", "a"])
        expectSuccess(parser: parser,
                      input: "a,a,a",
                      expected: ["a", "a", "a"])
        expectSuccess(parser: parser,
                      input: "a,a,a,a",
                      expected: ["a", "a", "a", "a"])
        expectSuccess(parser: parser,
                      input: "a,a,a,a,a",
                      expected: ["a", "a", "a", "a"])
        expectSuccess(parser: parser,
                      input: "a,ab",
                      expected: ["a", "a"])
        expectFailure(parser: parser,
                      input: "ab")
    }

    func testRepSepZeroMax() {
        let parser =
            char("a").rep(separator: char(","), max: 0)

        expectSuccess(parser: parser,
                      input: "",
                      expected: [])
        expectSuccess(parser: parser,
                      input: "a",
                      expected: [])
        expectSuccess(parser: parser,
                      input: "aa",
                      expected: [])
    }

    func testTuples() {
        let parser =
            (char("(") ~ char(" ").rep() ~ char(")")) ^^ { (values) -> String in
                let (open, inner, outer) = values
                return String([open] + inner + [outer])
            }

        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "ab")
        expectSuccess(parser: parser,
                      input: "()",
                      expected: "()")
        expectSuccess(parser: parser,
                      input: "( )",
                      expected: "( )")
        expectSuccess(parser: parser,
                      input: "(  )",
                      expected: "(  )")
    }

    func testRecursive() {
        let simple: Parser<String, Character> =
            (char("(") ~ char(")")) ^^^ "()"
        let parser: Parser<String, Character> =
            Parser.recursive { parser in
                let nested: Parser<String, Character> =
                    (char("(") ~ parser ~ char(")")) ^^ {
                        let (_, inner, _) = $0
                        return "(\(inner))"
                    }
                return simple || nested
            }

        expectSuccess(parser: parser,
                      input: "()",
                      expected: "()")
        expectSuccess(parser: parser,
                      input: "(())",
                      expected: "(())")
        expectSuccess(parser: parser,
                      input: "((()))",
                      expected: "((()))")
        expectFailure(parser: parser,
                      input: "(((")
        expectFailure(parser: parser,
                      input: "((()")
        expectFailure(parser: parser,
                      input: "((())")

        let longCount = 10000
        let long = String(repeating: "(", count: longCount)
             + String(repeating: ")", count: longCount)

        expectSuccess(parser: parser, input: long, expected: long)
    }

    func testNotFollowedBy() {

        let parser =
            notFollowedBy(char("a")) ^^^ true

        expectFailure(parser: parser,
                      input: "a")
        expectFailure(parser: parser,
                      input: "aa")
        expectSuccess(parser: parser,
                      input: "",
                      expected: true)
        expectSuccess(parser: parser,
                      input: "b",
                      expected: true)
        expectSuccess(parser: parser,
                      input: "ba",
                      expected: true)
    }

    func testFollowedBy() {
        let parser =
            followedBy(char("a")) ^^^ true

        expectSuccess(parser: parser,
                      input: "a",
                      expected: true)
        expectSuccess(parser: parser,
                      input: "aa",
                      expected: true)
        expectFailure(parser: parser,
                      input: "")
        expectFailure(parser: parser,
                      input: "b")
        expectFailure(parser: parser,
                      input: "ba")
    }

    static var allTests = [
        ("testAccept", testAccept),
        ("testLiteral", testLiteral),
        ("testMap", testMap),
        ("testMapValue", testMapValue),
        ("testSeq", testSeq),
        ("testSeq3", testSeq3),
        ("testSeq4", testSeq4),
        ("testSeq5", testSeq5),
        ("testSeqIgnoreLeft", testSeqIgnoreLeft),
        ("testSeqIgnoreRight", testSeqIgnoreRight),
        ("testOr", testOr),
        ("testCommitOr", testCommitOr),
        ("testOrFirstSuccess", testOrFirstSuccess),
        ("testOrLonger", testOrLonger),
        ("testCommitOrLonger", testCommitOrLonger),
        ("testOpt", testOpt),
        ("testRepNoMinNoMax", testRepNoMinNoMax),
        ("testRepMinNoMax", testRepMinNoMax),
        ("testRepMinMax", testRepMinMax),
        ("testRepZeroMax", testRepZeroMax),
        ("testRepError", testRepError),
        ("testRepSepNoMinNoMax", testRepSepNoMinNoMax),
        ("testRepSepMinNoMax", testRepSepMinNoMax),
        ("testRepSepMinMax", testRepSepMinMax),
        ("testRepSepZeroMax", testRepSepZeroMax),
        ("testTuples", testTuples),
        ("testRecursive", testRecursive),
        ("testNotFollowedBy", testNotFollowedBy),
        ("testFollowedBy", testFollowedBy)
    ]
}
