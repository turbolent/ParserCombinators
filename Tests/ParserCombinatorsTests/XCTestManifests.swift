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
        ("testCapturing2", testCapturing2),
        ("testCapturing3", testCapturing3),
        ("testChainLeft", testChainLeft),
        ("testCommitOr", testCommitOr),
        ("testCommitOrLongerDifferent", testCommitOrLongerDifferent),
        ("testCommitOrLongerSame", testCommitOrLongerSame),
        ("testEndOfInput", testEndOfInput),
        ("testFilter", testFilter),
        ("testFollowedBy", testFollowedBy),
        ("testLeftRecursion", testLeftRecursion),
        ("testLiteral", testLiteral),
        ("testMap", testMap),
        ("testMapValue", testMapValue),
        ("testNotFollowedBy", testNotFollowedBy),
        ("testOpt", testOpt),
        ("testOr", testOr),
        ("testOrErrorFirst", testOrErrorFirst),
        ("testOrErrorSecond", testOrErrorSecond),
        ("testOrFailure", testOrFailure),
        ("testOrFirstSuccess", testOrFirstSuccess),
        ("testOrLongerDifferent", testOrLongerDifferent),
        ("testOrLongerSameFirst", testOrLongerSameFirst),
        ("testOrLongerSameSecond", testOrLongerSameSecond),
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
