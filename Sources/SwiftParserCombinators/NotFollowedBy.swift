
// NOTE: never consumes any input (negative lookahead)
public func notFollowedBy<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<Void, Input>
{
    let lazyParser = Lazy(parser)
    return Parser { input in
        return lazyParser.value.step(input).map { result in
            if case .success = result {
                return .failure(message: "Expected failure", remaining: input)
            }

            return .success(value: (), remaining: input)
        }
    }
}
