
extension Parser {

    // Create a parser which sequentially composes another parser.
    // In case of failure,  back-tracking
    func seqCommit<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<(T, U), Input> {
        let lazyNext = Lazy({ commit(next()) })
        return flatMap { firstResult in
            lazyNext.value.map { secondResult in
                (firstResult, secondResult)
            }
        }
    }
}


func commit<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>) -> Parser<T, Input> {
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
