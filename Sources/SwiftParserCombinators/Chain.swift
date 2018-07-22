
import Foundation

extension Parser {

    public func chainLeft(_ separator: @autoclosure @escaping () -> Parser<(T, T) -> T, Element>,
                          empty: T,
                          min: Int = 0, max: Int? = nil)
        -> Parser<T, Element>
    {
        return SwiftParserCombinators.chainLeft(self,
                                                separator: separator,
                                                empty: empty,
                                                min: min,
                                                max: max)
    }
}

public func chainLeft<T, Element>(_ parser: @autoclosure @escaping () -> Parser<T, Element>,
                                  separator: @autoclosure @escaping () -> Parser<(T, T) -> T, Element>,
                                  empty: T,
                                  min: Int = 0,
                                  max: Int? = nil)
    -> Parser<T, Element>
{
    let lazyParser = Lazy(parser)
    let lazySeparator = Lazy(separator)

    let repeatingParser =
        lazyParser.value ~ (lazySeparator.value ~ lazyParser.value).rep(min: min, max: max)
            ^^ { firstAndRest -> T in
                let (first, rest) = firstAndRest
                return rest.reduce(first) { result, opAndValue -> T in
                    let (op, value) = opAndValue
                    return op(result, value)
                }
            }

    if min > 0 {
        return repeatingParser
    }

    return repeatingParser || success(empty)
}
