
import ParserCombinators


infix operator ^^ : ApplicativePrecedence

/// Creates a new parser from the given parser, that has the same behaviour as it,
/// but whose result is transformed by applying function `f`.
///
/// - Parameters:
///   - parser: The parser to be applied.
///   - f: A function that will be applied to the given parser's result.
///   - originalValue: The original result value.
///
public func ^^ <T, U, Element>(
    parser: Parser<T, Element>,
    f: @escaping (_ originalValue: T) throws -> U
)
    -> Parser<U, Element>
{
    return parser.map(f)
}

infix operator ^^^ : ApplicativePrecedence

/// Creates a new parser from the given parser, that has the same behaviour as it,
/// but whose result is always `value`, i.e., the original parse result is ignored.
///
/// - Parameters:
///   - parser: The parser to be applied.
///   - value: A value that will be used as the result.
///
public func ^^^ <T, U, Element>(
    parser: Parser<T, Element>,
    value: @autoclosure @escaping () -> U
)
    -> Parser<U, Element>
{
    return parser.map(value)
}


/// Creates a new parser from the given parser, that first applies it to the input,
/// and then, if the parse succeeded, applies the function `f` to the result,
/// and finally applies the parser returned by `f` to the remaining input.
///
/// This combinator is useful when a parser depends on the result of a previous parser.
///
/// - Parameters:
///   - parser:
///       The parser to be applied.
///   - f:
///       A function that, given the result from the first parser, returns the second parser
///       to be applied.
///   - originalValue:
///       The original result value.
///
public func >> <T, U, Element>(
    parser: Parser<T, Element>,
    f: @escaping (_ originalValue: T) -> Parser<U, Element>
)
    -> Parser<U, Element>
{
    return parser.flatMap(f)
}
