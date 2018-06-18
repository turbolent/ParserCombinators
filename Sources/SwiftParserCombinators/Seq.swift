
extension Parser {

    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>)
        -> Parser<(T, U), Input>
    {
        let lazyNext = Lazy(next)
        return flatMap { firstResult in
            lazyNext.value.map { secondResult in
                (firstResult, secondResult)
            }
        }
    }

    public func seqIgnoreLeft<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>)
        -> Parser<U, Input>
    {
        let lazyNext = Lazy(next)
        return flatMap { _ in lazyNext.value }
    }

    public func seqIgnoreRight<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>)
        -> Parser<T, Input>
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

public func ~ <T, Input>(lhs: Parser<T, Input>,
                         rhs: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<[T], Input>
{
    return lhs.seq(rhs).map { [$0, $1] }
}

public func ~ <T, Input>(lhs: Parser<[T], Input>,
                         rhs: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<[T], Input>
{
    return lhs.seq(rhs).map {
        var (xs, x) = $0
        xs.append(x)
        return xs
    }
}

public func ~ <T, U, Input>(lhs: Parser<T, Input>,
                            rhs: @autoclosure @escaping () -> Parser<U, Input>)
    -> Parser<(T, U), Input>
{
    return lhs.seq(rhs)
}

public func ~ <T, U, V, Input>(lhs: Parser<(T, U), Input>,
                               rhs: @autoclosure @escaping () -> Parser<V, Input>)
    -> Parser<(T, U, V), Input>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.1) }
}

public func ~ <T, U, V, W, Input>(lhs: Parser<(T, U, V), Input>,
                                  rhs: @autoclosure @escaping () -> Parser<W, Input>)
    -> Parser<(T, U, V, W), Input>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.1) }
}

public func ~ <T, U, V, W, X, Input>(lhs: Parser<(T, U, V, W), Input>,
                                     rhs: @autoclosure @escaping () -> Parser<X, Input>)
    -> Parser<(T, U, V, W, X), Input>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.1) }
}

public func ~ <T, U, V, W, X, Y, Input>(lhs: Parser<(T, U, V, W, X), Input>,
                                        rhs: @autoclosure @escaping () -> Parser<Y, Input>)
    -> Parser<(T, U, V, W, X, Y), Input>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.1) }
}

public func ~ <T, U, V, W, X, Y, Z, Input>(lhs: Parser<(T, U, V, W, X, Y), Input>,
                                        rhs: @autoclosure @escaping () -> Parser<Z, Input>)
    -> Parser<(T, U, V, W, X, Y, Z), Input>
{
    return lhs.seq(rhs).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.0.5, $0.1) }
}

// NOTE: actual defintition would be, but already defined in the standard definition as a workaround,
// see https://github.com/apple/swift/blob/48308411393e730cf3cb21d353a9be31045c47e4/stdlib/public/core/Policy.swift#L705
//infix operator ~> : ApplicativeSequencePrecedence

public func ~> <T, U, Input>(lhs: Parser<T, Input>,
                             rhs: @autoclosure @escaping () -> Parser<U, Input>)
    -> Parser<U, Input>
{
    return lhs.seqIgnoreLeft(rhs)
}

infix operator <~ : ApplicativeSequencePrecedence

public func <~ <T, U, Input>(lhs: Parser<T, Input>,
                             rhs: @autoclosure @escaping () -> Parser<U, Input>)
    -> Parser<T, Input>
{
    return lhs.seqIgnoreRight(rhs)
}
