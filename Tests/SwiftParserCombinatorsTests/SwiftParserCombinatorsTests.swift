import XCTest
import SwiftParserCombinators


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
        let parser: Parser<[String], Character> =
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
        let parser: Parser<[String], Character> =
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
        let parser: Parser<[String], Character> =
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
        let parser: Parser<[Character], Character> =
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
        let parser: Parser<[String], Character> =
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
        let parser: Parser<[Character], Character> =
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
        let parser: Parser<[String], Character> =
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
        let parser: Parser<[String], Character> =
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
        let parser: Parser<[Character], Character> =
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
            (char("(") ~ char(" ").rep() ~ char(")")).stringParser

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

    func testRecursive2() {
        let parser: Parser<String, Character> =
            Parser.recursive { parser -> Parser<String, Character> in
                ("1" ~ parser) ^^^ "" || "1"
            }

        let longCount = 200
        let long = String(repeating: "1", count: longCount)

        expectSuccess(parser: parser,
                      input: long,
                      expected: "")
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

    func testChainLeft() {

        typealias Op = (Int, Int) -> Int
        typealias OpParser = Parser<Op, Character>

        let addOp: OpParser =
            char("+") ^^^ (+) ||
            char("-") ^^^ (-)

        let mulOp: OpParser =
            char("*") ^^^ (*) ||
            char("/") ^^^ (/)

        let digit = `in`(.decimalDigits, kind: "digit")
        let num = digit.rep(min: 1) ^^ { (characters: [Character]) in
            Int(String(characters))!
        }

        let expr: Parser<Int, Character> =
            Parser.recursive { expr in
                let value = num
                    || (char("(") ~> expr) <~ char(")")
                let prod = value.chainLeft(mulOp, empty: 0)
                return prod.chainLeft(addOp, empty: 0)
        }

        expectSuccess(parser: expr,
                      input: "",
                      expected: 0)
        expectSuccess(parser: expr,
                      input: "(23+42)*3",
                      expected: 195)
        expectSuccess(parser: expr,
                      input: "23+42*3",
                      expected: 149)
    }

    func testLeftRecursion() {

        var exp: PackratParser<Int, Character>!
        var number: PackratParser<Int, Character>!
        var sum: PackratParser<Int, Character>!

        exp = PackratParser(parser:
            sum || number || ("(" ~> exp) <~ ")"
        )

        number = PackratParser(parser:
            elem(kind: "digit", predicate: { "0"..."9" ~= $0 })
                .rep(min: 1)
                .map { (characters: [Character]) in
                    let string = String(characters)
                    guard let number = Int(string) else {
                        throw MapError.failure("Invalid number: \(string)")
                    }
                    return number
            }
        )

        sum = PackratParser(parser:
            (exp ~ ("+" ~> exp)) ^^ { (numbers: [Int]) in
                numbers.reduce(0, +)
            }
        )

        expectError(parser: exp,
                    input: "((42+(23+1)))",
                    message: "left-recursion",
                    usePackratReader: true)
    }

    func testCapturing() {

        let anySeqCapture: Parser<Captures, Character> =
            (char("b") ^^^ 23) ~ (char("c") ^^^ true).capture("1")

        let captureSeqAnyCapture: Parser<Captures, Character> =
            (anySeqCapture ~ char("d")).capture("2")

        let repeatedCapture: Parser<Captures, Character> =
            (char("a") ^^^ 42).capture("1")

        let simpleCapture =
            char("e").capture("3")

        let p: Parser<Captures, Character> =
            (repeatedCapture ~ captureSeqAnyCapture ~ simpleCapture).capture("4")

        guard case .success(let captures, _) =
            p.parse(CollectionReader(collection: "abcde"))
        else {
            XCTFail("should have parsed")
            return
        }

        XCTAssertEqual(String(describing: captures.values),
                       String(describing: [42, 23, true, "d", "e"]))
        XCTAssertEqual(String(describing: captures.entries.sorted { $0.key < $1.key }),
                       String(describing: [
                         (key: "1", value: [[42], [true]]),
                         (key: "2", value: [[23, true, "d"]]),
                         (key: "3", value: [["e"]]),
                         (key: "4", value: [[42, 23, true, "d", "e"]])
                       ]))

    }

    func testSkipUntil() {
        let p: Parser<[Character], Character> =
            skipUntil(char("y") ~ char("z"))

        expectSuccess(parser: p,
                      input: "yz",
                      expected: ["y", "z"])

        expectSuccess(parser: p,
                      input: "yzA",
                      expected: ["y", "z"])

        expectSuccess(parser: p,
                      input: String(repeating: "x", count: 10) + "yz",
                      expected: ["y", "z"])

        expectFailure(parser: p,
                      input: String(repeating: "x", count: 10) + "y")

        expectFailure(parser: p,
                      input: "y")

        expectFailure(parser: p,
                      input: "")
    }

    func testSeqUnit() {
        let _: Parser<SwiftParserCombinators.Unit, Character> =
            char("y").map(Unit.empty) ~ char("z").map(Unit.empty)
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
        ("testRecursive2", testRecursive2),
        ("testNotFollowedBy", testNotFollowedBy),
        ("testFollowedBy", testFollowedBy),
        ("testChainLeft", testChainLeft),
        ("testLeftRecursion", testLeftRecursion),
        ("testCapturing", testCapturing),
        ("testSkipUntil", testSkipUntil)
    ]
}
