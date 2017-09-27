
extension Parser {

    public func not() -> Parser<Void, Input> {
        return SwiftParserCombinators.not(self)
    }
}

// NOTE: never consumes any input (negative lookahead)
public func not<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>) -> Parser<Void, Input> {
    return Parser { input in
        return parser().step(input).map { result in
            if case .success = result {
                return .failure(message: "Expected failure", remaining: input)
            }

            return .success(value: (), remaining: input)
        }
    }
}
