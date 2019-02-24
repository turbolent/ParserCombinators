
import XCTest
import ParserCombinators
import ParserCombinatorOperators
import DiffedAssertEqual

private func parse<T>(
    parser: Parser<T, Character>,
    input: String,
    usePackratReader: Bool = false
)
    -> ParseResult<T, Character>
{
    var reader: Reader<Character> =
        CollectionReader(collection: input)
    if usePackratReader {
        reader = PackratReader(underlying: reader)
    }
    return parser.parse(reader)
}

func expectSuccess<T>(
    parser: Parser<T, Character>,
    input: String,
    expected: T,
    usePackratReader: Bool = false,
    file: StaticString = #file,
    line: UInt = #line
)
    where T: Equatable
{
    let result = parse(
        parser: parser,
        input: input,
        usePackratReader: usePackratReader
    )
    switch result {
    case .success(let value, _):
        diffedAssertEqual(
            value,
            expected,
            file: file,
            line: line
        )
    case .failure, .error:
        XCTFail(
            String(describing: result),
            file: file,
            line: line
        )
    }
}

func expectSuccess<T>(
    parser: Parser<T, Character>,
    input: String,
    usePackratReader: Bool = false,
    file: StaticString = #file,
    line: UInt = #line
)
    where T: Equatable
{
    let result = parse(
        parser: parser,
        input: input,
        usePackratReader: usePackratReader
    )
    switch result {
    case .success:
        break
    case .failure, .error:
        XCTFail(
            String(describing: result),
            file: file,
            line: line
        )
    }
}

func expectSuccess<T>(
    parser: Parser<T?, Character>,
    input: String,
    expected: T?,
    usePackratReader: Bool = false,
    file: StaticString = #file,
    line: UInt = #line
)
    where T: Equatable
{
    let result = parse(
        parser: parser,
        input: input,
        usePackratReader: usePackratReader
    )
    switch result {
    case .success(let value, _):
        diffedAssertEqual(
            value,
            expected,
            file: file,
            line: line
        )
    case .failure, .error:
        XCTFail(
            String(describing: result),
            file: file,
            line: line
        )
    }
}

func expectSuccess<T>(
    parser: Parser<[T], Character>,
    input: String,
    expected: [T],
    usePackratReader: Bool = false,
    file: StaticString = #file,
    line: UInt = #line
)
    where T: Equatable
{
    let result = parse(
        parser: parser,
        input: input,
        usePackratReader: usePackratReader
    )
    switch result {
    case .success(let value, _):
        diffedAssertEqual(
            value,
            expected,
            file: file,
            line: line
        )
    case .failure, .error:
        XCTFail(
            String(describing: result),
            file: file,
            line: line
        )
    }
}

func expectFailure<T>(
    parser: Parser<T, Character>,
    input: String,
    message: String? = nil,
    usePackratReader: Bool = false,
    file: StaticString = #file,
    line: UInt = #line
) {
    let result = parse(
        parser: parser,
        input: input,
        usePackratReader: usePackratReader
    )
    switch result {
    case .success:
        XCTFail(
            "\(result) is successful",
            file: file,
            line: line
        )
    case .failure(let actualMessage, _):
        if let message = message {
            diffedAssertEqual(
                actualMessage,
                message,
                "Failure, but wrong message",
                file: file,
                line: line
            )
        }
    case .error:
        XCTFail(
            "\(result) is error",
            file: file,
            line: line
        )
    }
}

func expectError<T>(
    parser: Parser<T, Character>,
    input: String,
    message: String? = nil,
    usePackratReader: Bool = false,
    file: StaticString = #file,
    line: UInt = #line
) {
    let result = parse(
        parser: parser,
        input: input,
        usePackratReader: usePackratReader
    )
    switch result {
    case .success:
        XCTFail(
            "\(result) is successful",
            file: file,
            line: line
        )
    case .failure:
        XCTFail(
            "\(result) is failure",
            file: file,
            line: line
        )
    case .error(let actualMessage, _):
        if let message = message {
            diffedAssertEqual(
                actualMessage,
                message,
                "Error, but wrong message",
                file: file,
                line: line
            )
        }
    }
}

extension Parser where T == [Character] {
    var stringParser: Parser<String, Element> {
        return self ^^ { String($0) }
    }
}
