
import Trampoline


extension Parser {

    public func rep(min: Int = 0, max: Int? = nil) -> Parser<[T], Input> {
        return SwiftParserCombinators.rep(self, min: min, max: max)
    }
}

private func repStep<T, Input>(lazyParser: Lazy<Parser<T, Input>>, remaining: Input, elements: [T],
                               n: Int, min: Int = 0, max: Int?)
    -> Trampoline<ParseResult<[T], Input>>
{
    return More {
        if n == max {
            return Done(.success(value: elements, remaining: remaining))
        }

        return lazyParser.value.step(remaining).flatMap { result in
            switch result {
            case let .success(value, rest):
                var nextElements = elements
                nextElements.append(value)
                return repStep(lazyParser: lazyParser, remaining: rest, elements: nextElements,
                               n: n + 1, min: min, max: max)

            case let .failure(message2, remaining2):
                guard n >= min else {
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
                    return Done(.failure(message: message2, remaining: remaining2))
                }
                return Done(.success(value: elements, remaining: remaining))
            case let .error(message2, remaining2):
                guard n >= min else {
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
                    return Done(.error(message: message2, remaining: remaining2))
                }
                return Done(.success(value: elements, remaining: remaining))
            }
        }
    }
}


public func rep<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>,
                          min: Int = 0, max: Int? = nil)
    -> Parser<[T], Input>
{
    if let max = max, max == 0 {
        return success([])
    }

    return Parser { input in
        let lazyParser = Lazy(parser)

        return repStep(lazyParser: lazyParser, remaining: input, elements: [],
                       n: 0, min: min, max: max)
    }
}
