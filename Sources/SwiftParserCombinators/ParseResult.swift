
import Trampoline


/**
 A parse result can be either successful (`success`) or not.
 Non-successful results can be either failures (`failure`) or errors (`error`).
 Failures are non-fatal, errors are fatal.
 Successful results provide a result `value` of type `T`.
 Non-successful results provide a message explaining why the parse did not succeed.
 All results provide the remaining input to be parsed.
*/

public enum ParseResult<T, Input: Reader> {
    case success(value: T, remaining: Input)
    case failure(message: String, remaining: Input)
    case error(message: String, remaining: Input)

    public func map<U>(_ f: (T) -> U) -> ParseResult<U, Input> {
        switch self {
        case let .success(value, remaining):
            return .success(value: f(value), remaining: remaining)
        case let .failure(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .failure(message: message, remaining: remaining)
        case let .error(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .error(message: message, remaining: remaining)
        }
    }

    public func flatMapWithNext<U>(_ f: (T) -> Parser<U, Input>) -> Trampoline<ParseResult<U, Input>> {
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
