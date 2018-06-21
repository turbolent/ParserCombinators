
extension Parser {

    // Create a parser which sequentially composes another parser.
    // In case of failure, no back-tracking is performed
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
