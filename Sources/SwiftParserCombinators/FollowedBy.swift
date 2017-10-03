
// NOTE: never consumes any input (positive lookahead)
public func followedBy<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<T, Input>
{
    let lazyParser = Lazy(parser)
    return Parser { input in
        return lazyParser.value.step(input).map { result in
            if case .success(let value, _) = result {
                return .success(value: value, remaining: input)
            }

            return result
        }
    }
}

