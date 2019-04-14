
import XCTest
import ParserCombinators
import ParserDescription
import ParserDescriptionOperators


extension String: Token {

    public func isTokenLabel(_ label: String, equalTo conditionInput: String) -> Bool {
        return label == "text"
            && self == conditionInput
    }

    public func doesTokenLabel(_ label: String, havePrefix prefix: String) -> Bool {
        return label == "text"
            && self.starts(with: prefix)
    }

    public func isTokenLabel(
        _ label: String,
        matchingRegularExpression: NSRegularExpression
        ) -> Bool {
        return false
    }
}


final class PatternsTests: XCTestCase {

    func testCompilation() throws {
        let tokenPattern = TokenPattern(condition:
            LabelCondition(label: "text", op: .isEqualTo, input: "foo")
                || LabelCondition(label: "text", op: .isEqualTo, input: "bar")
        )
        let pattern = tokenPattern.capture("token").rep(min: 1)

        let parser: Parser<Captures, String> = try pattern.compile()

        let reader = CollectionReader(collection: ["foo", "foo", "bar", "baz"])

        guard case .success(let captures, _) = parser.parse(reader) else {
            XCTFail("parsing should succeed")
            return
        }

        XCTAssertEqual(
            String(describing: captures.values),
            String(describing: ["foo", "foo", "bar"])
        )

        XCTAssertEqual(
            String(describing: captures.entries.sorted { $0.key < $1.key }),
            String(describing: [(key: "token", value: [["foo"], ["foo"], ["bar"]])])
        )
    }
}
