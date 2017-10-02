
import Trampoline


extension Parser {

    public func rep(min: Int = 0, max: Int? = nil) -> Parser<[T], Input> {
        return SwiftParserCombinators.rep(self, min: min, max: max)
    }

    public func rep(n: Int) -> Parser<[T], Input> {
        return SwiftParserCombinators.rep(self, min: n, max: n)
    }

    public func rep<U>(separator: @autoclosure @escaping () -> Parser<U, Input>,
                       min: Int = 0, max: Int? = nil)
        -> Parser<[T], Input>
    {
        return SwiftParserCombinators.rep(self, separator: separator, min: min, max: max)
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
    if let max = max {
        guard min <= max else {
            fatalError("Can't parse min \(min) times and max \(max) times")
        }

        if max == 0 {
            return success([])
        }
    }

    return Parser { input in
        let lazyParser = Lazy(parser)

        return repStep(lazyParser: lazyParser, remaining: input, elements: [],
                       n: 0, min: min, max: max)
    }
}

public func rep<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>,
                          n: Int)
    -> Parser<[T], Input>
{
    return rep(parser, min: n, max: n)
}

public func rep<T, U, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>,
                             separator: @autoclosure @escaping () -> Parser<U, Input>,
                             min: Int = 0,
                             max: Int? = nil)
    -> Parser<[T], Input>
{
    if let max = max {
        guard min <= max else {
            fatalError("Can't parse min \(min) times and max \(max) times")
        }

        if max == 0 {
            return success([])
        }
    }

    let lazyParser = Lazy(parser)
    let lazySeparator = Lazy(separator)

    let repeatingParser: Parser<[T], Input> = {
        if let max = max, max == 1 {
            return lazyParser.value ^^ { [$0] }
        }

        let repeatingMax: Int? = {
            if let max = max {
                return max - 1
            }

            return nil
        }()

        let more = rep(lazySeparator.value ~> lazyParser.value,
                       min: min - 1,
                       max: repeatingMax)

        return lazyParser.value ~ more ^^ {
            var (first, remaining) = $0
            remaining.insert(first, at: 0)
            return remaining
        }
    }()

    if min > 0 {
        return repeatingParser
    }

    return repeatingParser || success([])
}
