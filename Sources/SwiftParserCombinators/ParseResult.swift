
import Trampoline

public enum MapError: Error {
    case failure(String)
    case error(String)
}


/**
 A parse result can be either successful (`success`) or not.
 Non-successful results can be either failures (`failure`) or errors (`error`).
 Failures are non-fatal, errors are fatal.
 Successful results provide a result `value` of type `T`.
 Non-successful results provide a message explaining why the parse did not succeed.
 All results provide the remaining input to be parsed.
*/

public enum ParseResult<T, Element> {
    public typealias Remaining = Reader<Element>

    case success(value: T, remaining: Remaining)
    case failure(message: String, remaining: Remaining)
    case error(message: String, remaining: Remaining)

    public var remaining: Remaining {
        switch self {
        case .success(_, let remaining):
            return remaining
        case .failure(_, let remaining):
            return remaining
        case .error(_, let remaining):
            return remaining
        }
    }

    public func map<U>(_ f: (T) throws -> U) -> ParseResult<U, Element> {
        switch self {
        case let .success(value, remaining):
            do {
                let newValue = try f(value)
                return .success(value: newValue, remaining: remaining)
            } catch MapError.failure(let message)  {
                return .failure(message: message, remaining: remaining)
            } catch MapError.error(let message) {
                return .error(message: message, remaining: remaining)
            } catch let error {
                return .failure(message: "map failed with error: \(error)",
                                remaining: remaining)
            }
        case let .failure(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .failure(message: message, remaining: remaining)
        case let .error(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .error(message: message, remaining: remaining)
        }
    }

    public func flatMapWithNext<U>(_ f: (T) -> Parser<U, Element>) -> Trampoline<ParseResult<U, Element>> {
        switch self {
        case let .success(value, remaining):
            return f(value).step(remaining)

        case let .failure(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return Done(.failure(message: message, remaining: remaining))

        case let .error(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return Done(.error(message: message, remaining: remaining))
        }
    }
}


extension ParseResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .success(value, remaining):
            return "[\(remaining.position)] parsed: \(value)"

        case let .failure(message, remaining):
            return "[\(remaining.position)] failure: \(message)\n\n\(remaining.position.longDescription)"

        case let .error(message, remaining):
            return "[\(remaining.position)] error: \(message)\n\n\(remaining.position.longDescription)"
        }
    }
}


public func success<T, Input>(_ value: T) -> Parser<T, Input> {
    return Parser { input in
        Done(.success(value: value, remaining: input))
    }
}

public func failure<T, Input>(_ message: String) -> Parser<T, Input> {
    return Parser { input in
        Done(.failure(message: message, remaining: input))
    }
}

public func error<T, Input>(_ message: String) -> Parser<T, Input> {
    return Parser { input in
        Done(.error(message: message, remaining: input))
    }
}
