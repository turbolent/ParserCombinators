
extension Parser {

    // TODO: wrap in OnceParser

    /// Create a parser which sequentially composes another parser in a non-backtracking fashion.
    /// In case of failure, no backtracking is performed.
    ///
    /// - Parameter next:
    ///     A parser that will be applied on the remaining input after this parser succeeds.
    ///
    /// - Returns:
    ///     A parser that -- on success -- returns a tuple that contains the result
    ///     of this parser and that of `next`. The parser fails if either this parser
    ///     or `next` fail, and the failure is fatal, i.e., an error.
    ///
    public func seqCommit<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<(T, U), Element>
    {
        let lazyNext = Lazy({ commit(next) })
        return flatMap { firstResult in
            lazyNext.value.map { secondResult in
                (firstResult, secondResult)
            }
        }
    }
}

/// Creates a new parser from the given parser, so that its failures become errors
/// (the `||` combinator will give up as soon as it encounters an error, on failure
/// it simply tries the next alternative).
///
/// - Parameter parser: The parser to be wrapped.
///
public func commit<T, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    let lazyParser = Lazy(parser)
    return Parser { input in
        lazyParser.value.step(input).map { result in
            switch result {
            case .success, .error:
                return result
            case let .failure(message, remaining):
                return .error(message: message, remaining: remaining)
            }
        }
    }
}
