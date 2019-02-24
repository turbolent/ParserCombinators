
import Trampoline


extension Parser {

    /// Creates a new parser from this parser, that has the same behaviour as it,
    /// but whose result is transformed by applying function `f`.
    ///
    /// - Parameters:
    ///   - f: A function that will be applied to this parser's result.
    ///   - originalValue: The original result value.
    ///
    public func map<U>(_ f: @escaping (_ originalValue: T) throws -> U)
        -> Parser<U, Element>
    {
        return Parser<U, Element> { input in
            self.step(input).map { $0.map(f) }
        }
    }

    /// Creates a new parser from this parser, that has the same behaviour as it,
    /// but whose result is always `value`, i.e., the original parse result is ignored.
    ///
    /// - Parameter value: A value that will be used as the result.
    ///
    public func map<U>(_ value: @autoclosure @escaping () -> U)
        -> Parser<U, Element>
    {
        let lazyValue = Lazy(value)
        return Parser<U, Element> { input in
            self.step(input).map {
                $0.map { _ in lazyValue.value }
            }
        }
    }

    /// Creates a new parser from this parser, that first applies it to the input,
    /// and then, if the parse succeeded, applies the function `f` to the result,
    /// and finally applies the parser returned by `f` to the remaining input.
    ///
    /// This combinator is useful when a parser depends on the result of a previous parser.
    ///
    /// - Parameters:
    ///   - f:
    ///       A function that, given the result from this parser, returns the second parser
    ///       to be applied.
    ///   - originalValue:
    ///       The original result value.
    ///
    public func flatMap<U>(_ f: @escaping (_ originalValue: T) -> Parser<U, Element>)
        -> Parser<U, Element>
    {
        return Parser<U, Element> { input in
            self.step(input).flatMap {
                $0.flatMapWithNext(f)
            }
        }
    }
}
