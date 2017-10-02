
import XCTest
import SwiftParserCombinators



indirect enum JSON {
    case null
    case string(String)
    case double(Double)
    case int(Int)
    case bool(Bool)
    case object([(String, JSON)])
    case array([JSON])
}


extension JSON: Equatable {}

func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null):
        return true
    case (.string(let a), .string(let b)):
        return a == b
    case (.double(let a), .double(let b)):
        return a == b
    case (.int(let a), .int(let b)):
        return a == b
    case (.bool(let a), .bool(let b)):
        return a == b
    case (.object(let a), .object(let b)):
        return a.lazy.map { $0.0 } == b.lazy.map { $0.0 }
            && a.lazy.map { $0.1 } == b.lazy.map { $0.1 }
    case (.array(let a), .array(let b)):
        return a == b
    default: return false
    }
}


let hexDigits = CharacterSet.decimalDigits
    .union(CharacterSet(charactersIn: "a"..."f"))
    .union(CharacterSet(charactersIn: "A"..."F"))


class JSONParser<Input: Reader> where Input.Element == Character {
    typealias CharacterParser = Parser<Character, Input>
    typealias CharactersParser = Parser<[Character], Input>
    typealias StringParser = Parser<String, Input>
    typealias VoidParser = Parser<Void, Input>
    typealias JSONParser = Parser<JSON, Input>

    static func json() -> JSONParser {
        return withWhitespace(value())
    }

    static func value() -> JSONParser {
        return primitive()
            || objectValue()
            || arrayValue()
            || numberValue()
            || stringValue()
    }

    static func primitive() -> JSONParser {
        return rep(`in`(.lowercaseLetters)) ^^ {
            switch String($0) {
            case "false":
                return .bool(false)
            case "true":
                return .bool(true)
            case "null":
                return .null
            case let letters:
                throw MapError.failure("invalid characters: \(letters)")
            }
        }
    }

    static func objectValue() -> JSONParser {
        let keyValue = withWhitespace(string()) ~ (structureChar(":") ~> json())
        let content = rep(keyValue, separator: char(",")) ^^ JSON.object
        return structure(start: "{", content: content, end: "}")
    }

    static func arrayValue() -> JSONParser {
        let content = rep(json(), separator: char(",")) ^^ JSON.array
        return structure(start: "[", content: content, end: "]")
    }

    static func structure<T>(start: Character, content: Parser<T, Input>, end: Character)
        -> Parser<T, Input>
    {
        return (structureChar(start) ~> content) <~ structureChar(end)
    }

    static func structureChar(_ character: Character) -> VoidParser {
        return withWhitespace(char(character)) ^^^ ()
    }

    static func withWhitespace<T>(_ parser: Parser<T, Input>) -> Parser<T, Input> {
        return (whitespace() ~> parser) <~ whitespace()
    }

    static func whitespace() -> VoidParser {
        return rep(`in`([" ", "\t", "\r", "\n"], kind: "whitespace")) ^^^ ()
    }

    static func `in`(_ characters: CharacterSet, kind: String = "") -> CharacterParser {
        return elem(kind: kind) { !$0.unicodeScalars.contains { !characters.contains($0) } }
    }

    static func notIn(_ characters: CharacterSet, kind: String = "") -> CharacterParser {
        return elem(kind: kind) { !$0.unicodeScalars.contains(where: characters.contains) }
    }

    static func hexDigit() -> CharacterParser {
        return `in`(hexDigits, kind: "hex-digit")
    }

    static func unicodeBlock() -> CharactersParser {
        return hexDigit().rep(n: 4)
    }

    static func charSeq() -> CharacterParser {
        return char("\\") ~> (
               char("\"") ^^^ Character("\"")
            || char("\\") ^^^ Character("\\")
            || char("/")  ^^^ Character("/")
            || char("b")  ^^^ Character("\u{8}")
            || char("f")  ^^^ Character("\u{12}")
            || char("n")  ^^^ Character("\n")
            || char("r")  ^^^ Character("\r")
            || char("t")  ^^^ Character("\t")
            || (char("u") ~> unicodeBlock())
                .rep(separator: char("\\"), max: 2) ^^ {
                    let codepoint: Int
                    if $0.count > 1 {
                        let high = parseHex(String($0[0]))
                        let low = parseHex(String($0[1]))
                        codepoint = decodeSurrogatePair(high: high, low: low)
                    } else {
                        codepoint = parseHex(String($0[0]))
                    }

                    guard let unicodeScalar = Unicode.Scalar(codepoint) else {
                        fatalError("Illegal codepoint")
                    }
                    return Character(unicodeScalar)
                }
        )
    }

    static func parseHex(_ value: String) -> Int {
        guard let codepoint = Int(value, radix: 16) else {
            fatalError("Illegal hex-value")
        }
        return codepoint
    }

    static func decodeSurrogatePair(high: Int, low: Int) -> Int {
        return ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
    }

    static func stringValue() -> JSONParser {
        return string() ^^ JSON.string
    }

    static func string() -> StringParser {
        let content = rep(charSeq() || notIn(CharacterSet(["\"", "\n"])))
        return ((char("\"") ~> content) <~ char("\"")) ^^ { String($0) }
    }

    static func numberValue() -> JSONParser {
        return opt(char("-") ^^ String.init) ~ intPart() ~ opt(fracPart()) ~ opt(expPart()) ^^ {
            let (minus, intPart, fracPart, expPart) = $0
            let value = optString("", minus) + intPart + optString(".", fracPart) + optString("", expPart)
            guard let int = Int(value) else {
                throw MapError.failure("Invalid number: \(value)")
            }
            return .int(int)
        }
    }

    static func sign() -> StringParser {
        return elem(kind: "sign") { $0 == "-" || $0 == "+" } ^^ String.init
    }

    static func exponent() -> StringParser {
        return elem(kind: "exponent") { $0 == "e" || $0 == "E" } ^^ String.init
    }

    static func nonZero() -> CharacterParser {
        return elem(kind: "non-zero digit") { $0 >= "1" && $0 <= "9" }
    }

    static func zero() -> StringParser {
        return char("0") ^^^ "0"
    }

    static func digit() -> CharacterParser {
        return `in`(.decimalDigits, kind: "digit")
    }

    static func intPart() -> StringParser {
        return zero() || intList()
    }

    static func intList() -> StringParser {
        return nonZero() ~ rep(digit()) ^^ {
            let (nonZero, digits) = $0
            return String(nonZero) + String(digits)
        }
    }

    static func fracPart() -> StringParser {
        return (char(".") ~> rep(digit())) ^^ { String($0) }
    }

    static func expPart() -> StringParser {
        return exponent() ~ opt(sign()) ~ rep(digit(), min: 1) ^^ {
            let (exponent, sign, digits) = $0
            return exponent + optString("", sign) + String(digits)
        }
    }

    private static func optString(_ pre: String, _ value: String?) -> String {
        guard let value = value else {
            return ""
        }
        return pre + value
    }
}


class JSONParserTests: XCTestCase {

    func testUnicode() {
        expectSuccess(parser: JSONParser.unicodeBlock() ^^ { String($0) },
                      input: "09Af",
                      expected: "09Af")
    }

    func testCharSeqUnicode() {
        expectSuccess(parser: JSONParser.charSeq(),
                      input: "\\u09Af",
                      expected: "য")
    }

    func testCharSeqUnicodeMultiple() {
        expectSuccess(parser: JSONParser.charSeq(),
                      input: "\\uD834\\uDD1E",
                      expected: "𝄞")
    }

    func testString() {
        expectSuccess(parser: JSONParser.string(),
                      input: "\"This is\\n a \\b test\"",
                      expected: "This is\n a \u{8} test")
    }

    func testJSON() {
        expectSuccess(parser: JSONParser<StringReader>.json(),
                      input: " [  null  , true,false  ,\"test\", [{}, { }, { \" \"  : \"23\" ,\"\": 42}]] ",
                      expected: JSON.array([.null, .bool(true), .bool(false), .string("test"),
                                            .array([.object([]),
                                                    .object([]),
                                                    .object([
                                                        (" ", .string("23")),
                                                        ("", .int(42))
                                                        ])])]))
    }

    static var allTests = [
        ("testUnicode", testUnicode),
        ("testCharSeqUnicode", testCharSeqUnicode),
        ("testCharSeqUnicodeMultiple", testCharSeqUnicodeMultiple),
        ("testString", testString),
        ("testJSON", testJSON)
    ]
}


