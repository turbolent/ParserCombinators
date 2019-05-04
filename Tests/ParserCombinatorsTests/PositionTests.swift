import XCTest
import ParserCombinators
import DiffedAssertEqual


class PositionTests: XCTestCase {

    func testStringsLongDescription() {
        let position = CollectionPosition(
            collection: ["foo", "bar", "baz", "qux"],
            index: 2
        )
        diffedAssertEqual(
            """
            foo bar baz qux
                    ^
            """,
            position.longDescription
        )
    }

    func testStringLongDescription() {
        let string = "test\ting"
        let index = string.index(string.startIndex, offsetBy: 5)
        let position = CollectionPosition(collection: string, index: index)
        diffedAssertEqual(
            """
            t e s t \t i n g
                    \t ^
            """,
            position.longDescription
        )
    }

}
