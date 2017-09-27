
extension Parser {

    public func `guard`() -> Parser<T, Input> {
        return SwiftParserCombinators.`guard`(self)
    }
}

// NOTE: never consumes any input (positive lookahead)
public func `guard`<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>) -> Parser<T, Input> {
    return Parser { input in
        return parser().step(input).map { result in
            if case .success(let value, _) = result {
                return .success(value: value, remaining: input)
            }

            return result
        }
    }
}

