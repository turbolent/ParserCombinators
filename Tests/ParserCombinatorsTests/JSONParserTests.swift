
import XCTest
import ParserCombinators
import ParserCombinatorOperators


indirect enum JSON {
    case null
    case string(String)
    case number(Double)
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
    case (.number(let a), .number(let b)):
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


class JSONParsers {
    typealias CharacterParser = Parser<Character, Character>
    typealias CharactersParser = Parser<[Character], Character>
    typealias StringParser = Parser<String, Character>
    typealias VoidParser = Parser<Void, Character>
    typealias JSONParser = Parser<JSON, Character>

    static let json: JSONParser =
        withWhitespace(value)

    static let value: JSONParser =
        primitive
            || numberValue
            || stringValue
            || objectValue
            || arrayValue

    static let primitive: JSONParser =
        `in`(.lowercaseLetters).rep().stringParser ^^ {
            switch $0 {
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

    static let objectValue: JSONParser = {
        let keyValue = withWhitespace(string) ~ (structureChar(":") ~> json)
        let content = keyValue.rep(separator: char(",")) ^^ JSON.object
        return structure(start: "{", content: content, end: "}")
    }()

    static let arrayValue: JSONParser = {
        let content = json.rep(separator: char(",")) ^^ JSON.array
        return structure(start: "[", content: content, end: "]")
    }()

    static func structure<T>(start: Character, content: Parser<T, Character>, end: Character)
        -> Parser<T, Character>
    {
        return (structureChar(start) ~> content) <~ structureChar(end)
    }

    static func structureChar(_ character: Character) -> VoidParser {
        return withWhitespace(char(character)) ^^^ ()
    }

    static let hexDigit = `in`(hexDigits, kind: "hex-digit")

    static let unicodeBlock: Parser<[Character], Character> = hexDigit.rep(n: 4)

    static let doubleQuote = char("\"") ^^^ Character("\"")
    static let backslash = char("\\") ^^^ Character("\\")
    static let slash = char("/") ^^^ Character("/")
    static let bEscape = char("b") ^^^ Character("\u{8}")
    static let fEscape = char("f") ^^^ Character("\u{12}")
    static let nEscape = char("n") ^^^ Character("\n")
    static let rEscape = char("r") ^^^ Character("\r")
    static let tEscape = char("t") ^^^ Character("\t")

    static let unicodeEscape: Parser<Character, Character> =
        (char("u") ~> unicodeBlock)
            .rep(separator: char("\\"), max: 2) ^^ { (characters: [[Character]]) -> Character in
                let codepoint: Int
                    if characters.count > 1 {
                        let high = parseHex(String(characters[0]))
                        let low = parseHex(String(characters[1]))
                        codepoint = decodeSurrogatePair(high: high, low: low)
                    } else {
                        codepoint = parseHex(String(characters[0]))
                    }

                    guard let unicodeScalar = Unicode.Scalar(codepoint) else {
                        fatalError("Illegal codepoint")
                    }
                    return Character(unicodeScalar)
                }

    static let charSeq =
        char("\\") ~> (
            doubleQuote
            || backslash
            || slash
            || bEscape
            || fEscape
            || nEscape
            || rEscape
            || tEscape
            || unicodeEscape
        )

    static func parseHex(_ value: String) -> Int {
        guard let codepoint = Int(value, radix: 16) else {
            fatalError("Illegal hex-value")
        }
        return codepoint
    }

    static func decodeSurrogatePair(high: Int, low: Int) -> Int {
        return ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
    }

    static let stringValue = string ^^ JSON.string

    static let string: StringParser = {
        let content: Parser<[Character], Character> =
            (charSeq || notIn(["\"", "\n"])).rep()
        return ((char("\"") ~> content) <~ char("\"")).stringParser
    }()

    static let numberValue: JSONParser =
        opt(char("-") ^^ String.init) ~ intPart ~ opt(fracPart) ~ opt(expPart) ^^ {
            let (minus, intPart, fracPart, expPart) = $0
            let value = optString("", minus) + intPart + optString(".", fracPart) + optString("", expPart)
            guard let double = Double(value) else {
                throw MapError.failure("Invalid number: \(value)")
            }
            return .number(double)
        }

    static let sign: StringParser =
        elem(kind: "sign") { $0 == "-" || $0 == "+" } ^^ String.init

    static let exponent: StringParser =
        elem(kind: "exponent") { $0 == "e" || $0 == "E" } ^^ String.init

    static let nonZero: CharacterParser =
        elem(kind: "non-zero digit") { $0 >= "1" && $0 <= "9" }

    static let zero: StringParser = "0" ^^^ "0"

    static let digit = `in`(.decimalDigits, kind: "digit")

    static let intPart = zero || intList

    static let intList = (nonZero ~ digit.rep()).stringParser

    static let fracPart = ("." ~> digit.rep()).stringParser

    static let expPart: StringParser =
        (exponent ~ opt(sign) ~ digit.rep(min: 1))
            .map { (parts: (String, String?, [Character])) in
                let (exponent, sign, digits) = parts
                return exponent + optString("", sign) + String(digits)
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
        expectSuccess(parser: JSONParsers.unicodeBlock ^^ { String($0) },
                      input: "09Af",
                      expected: "09Af")
    }

    func testCharSeqUnicode() {
        expectSuccess(parser: JSONParsers.charSeq,
                      input: "\\u09Af",
                      expected: "য")
    }

    func testCharSeqUnicodeMultiple() {
        expectSuccess(parser: JSONParsers.charSeq,
                      input: "\\uD834\\uDD1E",
                      expected: "𝄞")
    }

    func testString() {
        expectSuccess(parser: JSONParsers.string,
                      input: "\"This is\\n a \\b test\"",
                      expected: "This is\n a \u{8} test")
    }

    func testJSON() {
        expectSuccess(
            parser: JSONParsers.json,
            input: " [  null  , true,false  ,\"test\", [{}, { }, { \" \"  : \"23\" ,\"\": 42.23}]] ",
            expected: JSON.array([
              .null,
              .bool(true),
              .bool(false),
              .string("test"),
              .array([
                  .object([]),
                  .object([]),
                  .object([
                      (" ", .string("23")),
                      ("", .number(42.23))
                  ])
              ])
            ])
        )
    }

    func testJSONSpeed() {
        measure {
            for _ in 0..<10 {
                expectSuccess(
                    parser: JSONParsers.json,
                    input: " [  null  , true,false  ,\"test\", [{}, { }, { \" \"  : \"23\" ,\"\": 42.23}]] "
                )
            }
        }
    }
}
