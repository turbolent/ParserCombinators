
import ParserCombinators


infix operator ||| : LogicalDisjunctionPrecedence

/// Creates a new parser that succeeds if the first parser or the alternative parser succeeds.
/// If both parsers succeed, the result of the new parser is the result of the parser
/// that consumed the most elements.
///
/// - Note:
///     The alternative parser is only tried if the first parser's failure is non-fatal,
///     i.e. not an error, and so backtracking is allowed.
///
/// - Parameters:
///   - first: A parser that will be applied first.
///   - alternative: A parser that will be applied if the first parser fails.
///
public func ||| <T, U, Element>(
    first: Parser<T, Element>,
    alternative: @autoclosure @escaping () -> Parser<U, Element>
)
    -> Parser<Either<T, U>, Element>
{
    return first.orLonger(alternative)
}

/// Creates a new parser that succeeds if the first parser or the alternative parser succeeds.
/// If both parsers succeed, the result of the new parser is the result of the parser
/// that consumed the most elements.
///
/// - Note:
///     The alternative parser is only tried if the first parser's failure is non-fatal,
///     i.e. not an error, and so backtracking is allowed.
///
/// - Parameters:
///   - first: A parser that will be applied first.
///   - alternative: A parser that will be applied if the first parser fails.
///
public func ||| <T, Element>(
    first: Parser<T, Element>,
    alternative: @autoclosure @escaping () -> Parser<T, Element>
)
    -> Parser<T, Element>
{
    return first.orLonger(alternative)
}
