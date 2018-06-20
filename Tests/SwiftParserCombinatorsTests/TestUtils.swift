
import XCTest
import SwiftParserCombinators


func expectSuccess<T>(parser: Parser<T, CollectionReader<String>>, input: String, expected: T) where T: Equatable {
    let reader = CollectionReader(collection: input)
    let result = parser.parse(reader)
    switch result {
    case .success(let value, _):
        XCTAssertEqual(value, expected)
    case .failure, .error:
        XCTFail(String(describing: result))
    }
}

func expectSuccess<T>(parser: Parser<T?, CollectionReader<String>>, input: String, expected: T?) where T: Equatable {
    let reader = CollectionReader(collection: input)
    let result = parser.parse(reader)
    switch result {
    case .success(let value, _):
        XCTAssertEqual(value, expected)
    case .failure, .error:
        XCTFail(String(describing: result))
    }
}

func expectSuccess<T>(parser: Parser<[T], CollectionReader<String>>, input: String, expected: [T]) where T: Equatable {
    let reader = CollectionReader(collection: input)
    let result = parser.parse(reader)
    switch result {
    case .success(let value, _):
        XCTAssertEqual(value, expected)
    case .failure, .error:
        XCTFail(String(describing: result))
    }
}

func expectFailure<T>(parser: Parser<T, CollectionReader<String>>, input: String) {
    let reader = CollectionReader(collection: input)
    let result = parser.parse(reader)
    switch result {
    case .success:
        XCTFail("\(result) is successful")
    case .failure:
        break
    case .error:
        XCTFail("\(result) is error")
    }
}

func expectError<T>(parser: Parser<T, CollectionReader<String>>, input: String) {
    let reader = CollectionReader(collection: input)
    let result = parser.parse(reader)
    switch result {
    case .success:
        XCTFail("\(result) is successful")
    case .failure:
        XCTFail("\(result) is failure")
    case .error:
        break
    }
}
