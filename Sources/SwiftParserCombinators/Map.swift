
import Trampoline


extension Parser {
    public func map<U>(_ f: @escaping (T) throws -> U) -> Parser<U, Element> {
        return Parser<U, Element> { input in
            self.step(input).map { $0.map(f) }
        }
    }

    public func map<U>(_ value: @autoclosure @escaping () -> U) -> Parser<U, Element> {
        let lazyValue = Lazy(value)
        return Parser<U, Element> { input in
            self.step(input).map { $0.map { _ in lazyValue.value } }
        }
    }

    public func flatMap<U>(_ f: @escaping (T) -> Parser<U, Element>) -> Parser<U, Element> {
        return Parser<U, Element> { input in
            self.step(input).flatMap { $0.flatMapWithNext(f) }
        }
    }
}


infix operator ^^ : ApplicativePrecedence

public func ^^ <T, U, Element>(lhs: Parser<T, Element>,
                               rhs: @escaping (T) throws -> U)
    -> Parser<U, Element>
{
    return lhs.map(rhs)
}

infix operator ^^^ : ApplicativePrecedence

public func ^^^ <T, U, Element>(lhs: Parser<T, Element>,
                                rhs: @autoclosure @escaping () -> U)
    -> Parser<U, Element>
{
    return lhs.map(rhs)
}
