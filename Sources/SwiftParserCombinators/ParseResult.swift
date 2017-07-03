
enum ParseResult<T, Input: Reader> {
    case success(value: T, remaining: Input)
    case failure(message: String, remaining: Input)

    func map<U>(_ f: (T) -> U) -> ParseResult<U, Input> {
        switch self {
        case .success(let value, let remaining):
            return .success(value: f(value), remaining: remaining)
        case .failure(let message, let remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .failure(message: message, remaining: remaining)
        }
    }

    func flatMapWithNext<U>(_ f: (T) -> Parser<U, Input>) -> ParseResult<U, Input> {
        switch self {
        case .success(let value, let remaining):
            return f(value).parse(remaining)
        case .failure(let message, let remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
            return .failure(message: message, remaining: remaining)
        }
    }

    func append<U>(_ alternative: @autoclosure () -> ParseResult<U, Input>) -> ParseResult<U, Input> {
        switch self {
        case .success(let value, let remaining):
            // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here.
            // Furthermore it is not possible in Swift constrain U to be a supertype of T
            return .success(value: value as! U, remaining: remaining)
        case .failure(let message, let remaining):
            let alt = alternative()
            switch alt {
            case .success:
                return alt
            case .failure(_, let altRemaining):
                if altRemaining.pos < remaining.pos {
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here
                    return .failure(message: message, remaining: remaining)
                } else {
                    return alt
                }
            }
        }
    }
}

