
/**
 A parse result can be either successful (`success`) or not.
 Non-successful results can be either failures (`failure`) or errors (`error`).
 Failures are non-fatal, errors are fatal.
 Successful results provide a result `value` of type `T`.
 Non-successful results provide a message explaining why the parse did not succeed.
 All results provide the remaining input to be parsed.
*/

enum ParseResult<T, Input: Reader> {
    case success(value: T, remaining: Input)
    case failure(message: String, remaining: Input)
    case error(message: String, remaining: Input)

    func map<U>(_ f: (T) -> U) -> ParseResult<U, Input> {
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

    func flatMapWithNext<U>(_ f: (T) -> Parser<U, Input>) -> ParseResult<U, Input> {
        switch self {
        case let .success(value, remaining):
            return f(value).parse(remaining)

        case let .failure(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .failure(message: message, remaining: remaining)

        case let .error(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .error(message: message, remaining: remaining)
        }
    }

    func append<U>(_ alternative: @autoclosure () -> ParseResult<U, Input>) -> ParseResult<U, Input> {
        switch self {
        case let .success(value, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here.
            // Furthermore it is not possible in Swift constrain U to be a supertype of T
            return .success(value: value as! U, remaining: remaining)

        case let .error(message, remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here.
            return .error(message: message, remaining: remaining)

        case let .failure(message, remaining):
            let alt = alternative()

            switch alt {
            case .success:
                return alt
            case .failure(_, let altRemaining):
                if altRemaining.offset < remaining.offset {
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
                    return .failure(message: message, remaining: remaining)
                }
                return alt
            case .error(_, let altRemaining):
                if altRemaining.offset < remaining.offset {
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
                    return .error(message: message, remaining: remaining)
                }
                return alt
            }
        }
    }
}

extension ParseResult: CustomStringConvertible {
    var description: String {
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


func success<T, Input>(_ value: T) -> Parser<T, Input> {
    return Parser { input in
        .success(value: value, remaining: input)
    }
}

func failure<T, Input>(_ message: String) -> Parser<T, Input> {
    return Parser { input in
        .failure(message: message, remaining: input)
    }
}

func error<T, Input>(_ message: String) -> Parser<T, Input> {
    return Parser { input in
        .error(message: message, remaining: input)
    }
}
