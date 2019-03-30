
import Trampoline


extension Parser {

    /// Creates a new parser that repeatedly applies this parser until it fails,
    /// and returns all parsed values.
    ///
    /// - Parameters:
    ///   - min:
    ///       The minumum number of times this parser needs to succeed.
    ///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
    ///       i.e. not an error, and so backtracking is allowed.
    ///   - max:
    ///       The maximum number of times this parser is to be applied.
    ///
    public func rep<U: Sequenceable>(min: Int = 0, max: Int? = nil) -> Parser<U, Element>
        where U.Element == T
    {
        return ParserCombinators.rep(self, min: min, max: max)
    }

    /// Creates a new parser that repeatedly applies this parser until it fails,
    /// and returns all parsed values.
    ///
    /// - Parameters:
    ///   - min:
    ///       The minumum number of times this parser needs to succeed.
    ///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
    ///       i.e. not an error, and so backtracking is allowed.
    ///   - max:
    ///       The maximum number of times this parser is to be applied.
    ///
    public func rep<U: AnySequenceable>(min: Int = 0, max: Int? = nil) -> Parser<U, Element> {
        return ParserCombinators.rep(self, min: min, max: max)
    }

    /// Creates a new parser that repeatedly applies this parser the given number of times,
    /// and returns all parsed values.
    ///
    /// - Parameter n:
    ///     The number of times this parser is applied and needs to succeed.
    ///     If the parser succeeds fewer times, the new parser returns a non-fatal failure,
    ///     i.e. not an error, and so backtracking is allowed.
    ///
    public func rep<U: Sequenceable>(n: Int) -> Parser<U, Element>
        where U.Element == T
    {
        return ParserCombinators.rep(self, min: n, max: n)
    }

    /// Creates a new parser that repeatedly applies this parser the given number of times,
    /// and returns all parsed values.
    ///
    /// - Parameter n:
    ///     The number of times this parser is applied and needs to succeed.
    ///     If the parser succeeds fewer times, the new parser returns a non-fatal failure,
    ///     i.e. not an error, and so backtracking is allowed.
    ///
    public func rep<U: AnySequenceable>(n: Int) -> Parser<U, Element> {
        return ParserCombinators.rep(self, min: n, max: n)
    }

    /// Creates a new parser that repeatedly applies this parser interleaved with
    /// the separating parser, until it fails, and returns all parsed values.
    ///
    /// - Parameters:
    ///   - separator:
    ///       The parser that separates the occurrences of this parser.
    ///   - min:
    ///       The minumum number of times this parser needs to succeed.
    ///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
    ///       i.e. not an error, and so backtracking is allowed.
    ///   - max:
    ///       The maximum number of times this parser is to be applied.
    ///
    public func rep<U, V: Sequenceable>(
        separator: @autoclosure @escaping () -> Parser<U, Element>,
        min: Int = 0, max: Int? = nil
    )
        -> Parser<V, Element>
        where V.Element == T
    {
        return ParserCombinators.rep(self, separator: separator(), min: min, max: max)
    }

    /// Creates a new parser that repeatedly applies this parser interleaved with
    /// the separating parser, until it fails, and returns all parsed values.
    ///
    /// - Parameters:
    ///   - separator:
    ///       The parser that separates the occurrences of this parser.
    ///   - min:
    ///       The minumum number of times this parser needs to succeed.
    ///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
    ///       i.e. not an error, and so backtracking is allowed.
    ///   - max:
    ///       The maximum number of times this parser is to be applied.
    ///
    public func rep<U, V: AnySequenceable>(
        separator: @autoclosure @escaping () -> Parser<U, Element>,
        min: Int = 0, max: Int? = nil
    )
        -> Parser<V, Element>
    {
        return ParserCombinators.rep(self, separator: separator(), min: min, max: max)
    }
}

private func repStep<T, U, Element>(
    lazyParser: Lazy<Parser<T, Element>>,
    remaining: Reader<Element>,
    elements: U,
    n: Int, min: Int = 0, max: Int?,
    sequence: @escaping (U, T) -> U
)
    -> Trampoline<ParseResult<U, Element>>
{
    return More {
        if n == max {
            return Done(.success(value: elements, remaining: remaining))
        }

        return lazyParser.value.step(remaining).flatMap { result in
            switch result {
            case let .success(value, rest):
                let nextElements = sequence(elements, value)
                return repStep(lazyParser: lazyParser, remaining: rest, elements: nextElements,
                               n: n + 1, min: min, max: max, sequence: sequence)

            case let .failure(message2, remaining2):
                guard n >= min else {
                    // NOTE: unfortunately Swift doesn't have a bottom type,
                    // so can't use `result` here.
                    return Done(.failure(message: message2, remaining: remaining2))
                }
                return Done(.success(value: elements, remaining: remaining))

            case let .error(message2, remaining2):
                guard n >= min else {
                    // NOTE: unfortunately Swift doesn't have a bottom type,
                    // so can't use `result` here.
                    return Done(.error(message: message2, remaining: remaining2))
                }
                return Done(.success(value: elements, remaining: remaining))
            }
        }
    }
}

private func rep<T, U, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    min: Int = 0,
    max: Int? = nil,
    empty: @escaping () -> U,
    sequence: @escaping (U, T) -> U
)
    -> Parser<U, Element>
{
    if let max = max {
        guard min <= max else {
            fatalError("Can't parse min \(min) times and max \(max) times")
        }

        if max == 0 {
            return success(empty())
        }
    }

    let lazyParser = Lazy(parser)
    return Parser { input in
        repStep(
            lazyParser: lazyParser,
            remaining: input,
            elements: empty(),
            n: 0,
            min: min,
            max: max,
            sequence: sequence
        )
    }
}

/// Creates a new parser that repeatedly applies the given parser until it fails,
/// and returns all parsed values.
///
/// - Parameters:
///   - parser:
///       The parser to be applied successively to the input.
///   - min:
///       The minumum number of times the given parser needs to succeed.
///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///       i.e. not an error, and so backtracking is allowed.
///   - max:
///       The maximum number of times the given parser is to be applied.
///
public func rep<T, U: Sequenceable, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    min: Int = 0,
    max: Int? = nil
)
    -> Parser<U, Element>
    where U.Element == T
{
    return rep(
        parser(),
        min: min,
        max: max,
        empty: { U.empty },
        sequence: { $0.sequence(next: $1) }
    )
}

/// Creates a new parser that repeatedly applies the given parser until it fails,
/// and returns all parsed values.
///
/// - Parameters:
///   - parser:
///       The parser to be applied successively to the input.
///   - min:
///       The minumum number of times the given parser needs to succeed.
///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///       i.e. not an error, and so backtracking is allowed.
///   - max:
///       The maximum number of times the given parser is to be applied.
///
public func rep<T, U: AnySequenceable, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    min: Int = 0,
    max: Int? = nil
)
    -> Parser<U, Element>
{
    return rep(
        parser(),
        min: min,
        max: max,
        empty: { U.empty },
        sequence: { $0.sequence(next: $1) }
    )
}

/// Creates a new parser that repeatedly applies the given parser the given number of times,
/// and returns all parsed values.
///
/// - Parameters:
///   - parser:
///       The parser to be applied successively to the input.
///   - n:
///       The number of times the given parser is applied and needs to succeed.
///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///       i.e. not an error, and so backtracking is allowed.
///
public func rep<T, U: Sequenceable, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    n: Int
)
    -> Parser<U, Element>
    where U.Element == T
{
    return rep(parser(), min: n, max: n)
}

/// Creates a new parser that repeatedly applies the given parser the given number of times,
/// and returns all parsed values.
///
/// - Parameters:
///   - parser:
///       The parser to be applied successively to the input.
///   - n:
///       The number of times the given parser is applied and needs to succeed.
///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///       i.e. not an error, and so backtracking is allowed.
///
public func rep<T, U: AnySequenceable, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    n: Int
)
    -> Parser<U, Element>
{
    return rep(parser(), min: n, max: n)
}

/// Creates a new parser that repeatedly applies the given parser interleaved with
/// the separating parser, until it fails, and returns all parsed values.
///
/// - Parameters:
///   - parser:
///       The parser to be applied successively to the input.
///   - separator:
///       The parser that separates the occurrences of the given parser.
///   - min:
///       The minumum number of times the given parser needs to succeed.
///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///       i.e. not an error, and so backtracking is allowed.
///   - max:
///       The maximum number of times the given parser is to be applied.
///
public func rep<T, U, V: Sequenceable, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    separator: @autoclosure @escaping () -> Parser<U, Element>,
    min: Int = 0,
    max: Int? = nil
)
    -> Parser<V, Element>
    where V.Element == T
{
    return rep(
        parser(),
        separator: separator(),
        min: min,
        max: max,
        empty: { V.empty },
        sequenceValues: { $0.sequence(next: $1) },
        sequenceParsers: { $0.seq($1) }
    )
}

/// Creates a new parser that repeatedly applies the given parser interleaved with
/// the separating parser, until it fails, and returns all parsed values.
///
/// - Parameters:
///   - parser:
///       The parser to be applied successively to the input.
///   - separator:
///       The parser that separates the occurrences of the given parser.
///   - min:
///       The minumum number of times the given parser needs to succeed.
///       If the parser succeeds fewer times, the new parser returns a non-fatal failure,
///       i.e. not an error, and so backtracking is allowed.
///   - max:
///       The maximum number of times the given parser is to be applied.
///
public func rep<T, U, V: AnySequenceable, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    separator: @autoclosure @escaping () -> Parser<U, Element>,
    min: Int = 0,
    max: Int? = nil
)
    -> Parser<V, Element>
{
    return rep(
        parser(),
        separator: separator(),
        min: min,
        max: max,
        empty: { V.empty },
        sequenceValues: { $0.sequence(next: $1) },
        sequenceParsers: { $0.seq($1) }
    )
}

private func rep<T, U, V, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    separator: @autoclosure @escaping () -> Parser<U, Element>,
    min: Int = 0,
    max: Int? = nil,
    empty: @escaping () -> V,
    sequenceValues: @escaping (V, T) -> V,
    sequenceParsers: @escaping (Parser<T, Element>, Parser<V, Element>) -> Parser<V, Element>
)
    -> Parser<V, Element>
{
    if let max = max {
        guard min <= max else {
            fatalError("Can't parse min \(min) times and max \(max) times")
        }

        if max == 0 {
            return success(empty())
        }
    }

    let lazyParser = Lazy(parser)
    let lazySeparator = Lazy(separator)

    let repeatingParser: Parser<V, Element> = {
        if let max = max, max == 1 {
            return lazyParser.value.map {
                // TODO: enough to call empty once?
                sequenceValues(empty(), $0)
            }
        }

        let repeatingMax: Int? = {
            if let max = max {
                return max - 1
            }

            return nil
        }()

        let more: Parser<V, Element> =
            rep(lazySeparator.value.seqIgnoreLeft(lazyParser.value),
                min: min - 1,
                max: repeatingMax,
                empty: empty,
                sequence: sequenceValues)

        return sequenceParsers(lazyParser.value, more)
    }()

    if min > 0 {
        return repeatingParser
    }

    let successParser: Parser<V, Element> = success(empty())

    return repeatingParser.or(successParser)
}
