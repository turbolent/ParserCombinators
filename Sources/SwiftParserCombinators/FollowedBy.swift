
// NOTE: never consumes any input (positive lookahead)
public func followedBy<T, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
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

