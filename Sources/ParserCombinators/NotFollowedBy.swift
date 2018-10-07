
/// Creates a new parser from the given parser, that succeeds if the given parser fails,
/// but does not consume any input. Otherwise it returns a non‐fatal failure, i.e., not an error.
///
/// This backtracking combinator allows negative lookahead, i.e., tentatively parsing input
/// and then backtracking if the parse failed.
///
/// - Parameter parser: The parser to be applied.
///
public func notFollowedBy<T, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<Void, Element>
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
