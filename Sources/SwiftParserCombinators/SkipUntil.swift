
import Trampoline

private func skipUntilStep<T, Element>(parser: Parser<T, Element>,
                                       remaining: Reader<Element>)
    -> Trampoline<ParseResult<T, Element>>
{
    return More {
        return parser.step(remaining).flatMap { result in
            switch result {
            case .success, .error:
                return Done(result)
            case .failure(_, let remaining):
                guard !remaining.atEnd else {
                    return Done(.failure(message: "end of input",
                                         remaining: remaining))
                }
                return skipUntilStep(parser: parser,
                                     remaining: remaining.rest())
            }
        }
    }
}

public func skipUntil<T, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    return Parser { input in
        let lazyParser = Lazy(parser)
        return skipUntilStep(parser: lazyParser.value,
                             remaining: input)
    }
}
