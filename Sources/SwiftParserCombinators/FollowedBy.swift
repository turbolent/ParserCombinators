
/// Creates a new parser from the given parser, that succeeds if the given parser succeeds,
/// but does not consume any input. Otherwise it returns a non‐fatal failure, i.e., not an error.
///
/// This backtracking combinator allows positive lookahead, i.e., tentatively parsing input
/// and then backtracking if the parse failed.
///
/// - Parameter parser: The parser to be applied.
///
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

