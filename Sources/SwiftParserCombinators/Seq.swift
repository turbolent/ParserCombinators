
extension Parser {

    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<(T, U), Element>
    {
        let lazyNext = Lazy(next)
        return flatMap { firstResult in
            lazyNext.value.map { secondResult in
                (firstResult, secondResult)
            }
        }
    }

    public func seqIgnoreLeft<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<U, Element>
    {
        let lazyNext = Lazy(next)
        return flatMap { _ in lazyNext.value }
    }

    public func seqIgnoreRight<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<T, Element>
    {
        let lazyNext = Lazy(next)
        return flatMap { firstResult in
            lazyNext.value.map { _ in
                firstResult
            }
        }
    }
}


infix operator ~: ApplicativePrecedence

public func ~ <T, Element>(lhs: Parser<T, Element>,
                           rhs: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<[T], Element>
{
    return lhs.seq(rhs).map { [$0, $1] }
}

public func ~ <T, Element>(lhs: Parser<[T], Element>,
                           rhs: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<[T], Element>
{
    return lhs.seq(rhs).map {
        var (xs, x) = $0
        xs.append(x)
        return xs
    }
}

public func ~ <T, U, Element>(lhs: Parser<T, Element>,
                              rhs: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<(T, U), Element>
{
    return lhs.seq(rhs)
}

public func ~ <T, U, V, Element>(lhs: Parser<(T, U), Element>,
                                 rhs: @autoclosure @escaping () -> Parser<V, Element>)
    -> Parser<(T, U, V), Element>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.1) }
}

public func ~ <T, U, V, W, Element>(lhs: Parser<(T, U, V), Element>,
                                    rhs: @autoclosure @escaping () -> Parser<W, Element>)
    -> Parser<(T, U, V, W), Element>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.1) }
}

public func ~ <T, U, V, W, X, Element>(lhs: Parser<(T, U, V, W), Element>,
                                       rhs: @autoclosure @escaping () -> Parser<X, Element>)
    -> Parser<(T, U, V, W, X), Element>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.1) }
}

public func ~ <T, U, V, W, X, Y, Element>(lhs: Parser<(T, U, V, W, X), Element>,
                                          rhs: @autoclosure @escaping () -> Parser<Y, Element>)
    -> Parser<(T, U, V, W, X, Y), Element>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.1) }
}

public func ~ <T, U, V, W, X, Y, Z, Element>(lhs: Parser<(T, U, V, W, X, Y), Element>,
                                             rhs: @autoclosure @escaping () -> Parser<Z, Element>)
    -> Parser<(T, U, V, W, X, Y, Z), Element>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.0.5, $0.1) }
}

// NOTE: actual defintition would be, but already defined in the standard definition as a workaround,
// see https://github.com/apple/swift/blob/48308411393e730cf3cb21d353a9be31045c47e4/stdlib/public/core/Policy.swift#L705
//infix operator ~> : ApplicativeSequencePrecedence

public func ~> <T, U, Element>(lhs: Parser<T, Element>,
                               rhs: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<U, Element>
{
    return lhs.seqIgnoreLeft(rhs)
}

infix operator <~ : ApplicativeSequencePrecedence

public func <~ <T, U, Element>(lhs: Parser<T, Element>,
                               rhs: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<T, Element>
{
    return lhs.seqIgnoreRight(rhs)
}
