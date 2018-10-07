import XCTest

extension JSONParserTests {
    static let __allTests = [
        ("testCharSeqUnicode", testCharSeqUnicode),
        ("testCharSeqUnicodeMultiple", testCharSeqUnicodeMultiple),
        ("testJSON", testJSON),
        ("testJSONSpeed", testJSONSpeed),
        ("testString", testString),
        ("testUnicode", testUnicode),
    ]
}

extension ParserCombinatorsTests {
    static let __allTests = [
        ("testAccept", testAccept),
        ("testCapturing", testCapturing),
        ("testChainLeft", testChainLeft),
        ("testCommitOr", testCommitOr),
        ("testCommitOrLonger", testCommitOrLonger),
        ("testEndOfInput", testEndOfInput),
        ("testFollowedBy", testFollowedBy),
        ("testLeftRecursion", testLeftRecursion),
        ("testLiteral", testLiteral),
        ("testMap", testMap),
        ("testMapValue", testMapValue),
        ("testNotFollowedBy", testNotFollowedBy),
        ("testOpt", testOpt),
        ("testOr", testOr),
        ("testOrFirstSuccess", testOrFirstSuccess),
        ("testOrLonger", testOrLonger),
        ("testRecursive", testRecursive),
        ("testRecursive2", testRecursive2),
        ("testRepError", testRepError),
        ("testRepMinMax", testRepMinMax),
        ("testRepMinNoMax", testRepMinNoMax),
        ("testRepNoMinNoMax", testRepNoMinNoMax),
        ("testRepSepMinMax", testRepSepMinMax),
        ("testRepSepMinNoMax", testRepSepMinNoMax),
        ("testRepSepNoMinNoMax", testRepSepNoMinNoMax),
        ("testRepSepZeroMax", testRepSepZeroMax),
        ("testRepZeroMax", testRepZeroMax),
        ("testSeq", testSeq),
        ("testSeq3", testSeq3),
        ("testSeq4", testSeq4),
        ("testSeq5", testSeq5),
        ("testSeqIgnoreLeft", testSeqIgnoreLeft),
        ("testSeqIgnoreRight", testSeqIgnoreRight),
        ("testSeqTuple", testSeqTuple),
        ("testSeqUnit", testSeqUnit),
        ("testSkipUntil", testSkipUntil),
        ("testTuples", testTuples),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JSONParserTests.__allTests),
        testCase(ParserCombinatorsTests.__allTests),
    ]
}
#endif
