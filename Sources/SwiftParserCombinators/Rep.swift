
import Trampoline


extension Parser {

    /// Creates a new parser that repeatedly applies this parser until it fails,
    /// and returns all parsed values.
    ///
    /// - Parameters:
    ///   - min: The minumum number of times this parser needs to succeed.
    ///          If the parser succeeds fewer times, the new parser returns
    ///          a non-fatal failure, i.e. not an error, and so backtracking
    ///          is allowed.
    ///   - max: The maximum number of times this parser is to be applied.
    ///
    public func rep(min: Int = 0, max: Int? = nil) -> Parser<[T], Element> {
        return SwiftParserCombinators.rep(self, min: min, max: max)
    }

    /// Creates a new parser that repeatedly applies this parser the given number of times,
    /// and returns all parsed values.
    ///
    /// - Parameter n: The number of times this parser is applied and needs to succeed.
    ///                If the parser succeeds fewer times, the new parser returns
    ///                a non-fatal failure, i.e. not an error, and so backtracking
    ///                is allowed.
    ///
    public func rep(n: Int) -> Parser<[T], Element> {
        return SwiftParserCombinators.rep(self, min: n, max: n)
    }

    /// Creates a new parser that repeatedly applies this parser interleaved with
    /// the separating parser, until it fails, and returns all parsed values.
    ///
    /// - Parameters:
    ///   - separator: The parser that separates the occurrences of this parser.
    ///   - min: The minumum number of times this parser needs to succeed.
    ///          If the parser succeeds fewer times, the new parser returns
    ///          a non-fatal failure, i.e. not an error, and so backtracking
    ///          is allowed.
    ///   - max: The maximum number of times this parser is to be applied.
    ///
    public func rep<U>(separator: @autoclosure @escaping () -> Parser<U, Element>,
                       min: Int = 0, max: Int? = nil)
        -> Parser<[T], Element>
    {
        return SwiftParserCombinators.rep(self, separator: separator, min: min, max: max)
    }
}

private func repStep<T, Element>(lazyParser: Lazy<Parser<T, Element>>,
                                 remaining: Reader<Element>,
                                 elements: [T],
                                 n: Int, min: Int = 0, max: Int?)
    -> Trampoline<ParseResult<[T], Element>>
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

/// Creates a new parser that repeatedly applies the given parser until it fails,
/// and returns all parsed values.
///
/// - Parameters:
///   - parser: The parser to be applied successively to the input.
///   - min: The minumum number of times the given parser needs to succeed.
///          If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///          i.e. not an error, and so backtracking is allowed.
///   - max: The maximum number of times the given parser is to be applied.
///
public func rep<T, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>,
                            min: Int = 0, max: Int? = nil)
    -> Parser<[T], Element>
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

/// Creates a new parser that repeatedly applies the given parser the given number of times,
/// and returns all parsed values.
///
/// - Parameters:
///   - parser: The parser to be applied successively to the input.
///   - n: The number of times the given parser is applied and needs to succeed.
///        If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///        i.e. not an error, and so backtracking is allowed.
///
public func rep<T, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>,
                            n: Int)
    -> Parser<[T], Element>
{
    return rep(parser, min: n, max: n)
}

/// Creates a new parser that repeatedly applies the given parser interleaved with
/// the separating parser, until it fails, and returns all parsed values.
///
/// - Parameters:
///   - parser: The parser to be applied successively to the input.
///   - separator: The parser that separates the occurrences of the given parser.
///   - min: The minumum number of times the given parser needs to succeed.
///          If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///          i.e. not an error, and so backtracking is allowed.
///   - max: The maximum number of times the given parser is to be applied.
///
public func rep<T, U, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>,
                               separator: @autoclosure @escaping () -> Parser<U, Element>,
                               min: Int = 0,
                               max: Int? = nil)
    -> Parser<[T], Element>
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

    let repeatingParser: Parser<[T], Element> = {
        if let max = max, max == 1 {
            return lazyParser.value ^^ { [$0] }
        }

        let repeatingMax: Int? = {
            if let max = max {
                return max - 1
            }

            return nil
        }()

        let more = rep(lazySeparator.value.seqIgnoreLeft(lazyParser.value),
                       min: min - 1,
                       max: repeatingMax)

        return lazyParser.value.seq(more)
    }()

    if min > 0 {
        return repeatingParser
    }

    let successParser: Parser<[T], Element> = success([])

    return repeatingParser || successParser
}
