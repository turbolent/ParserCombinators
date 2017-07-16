
extension Parser {

    func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<(T, U), Input> {
        var lazyNext = Lazy(next)
        return flatMap { firstResult in
            lazyNext.value.map { secondResult in
                (firstResult, secondResult)
            }
        }
    }

    func seqIgnoreLeft<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        var lazyNext = Lazy(next)
        return flatMap { _ in lazyNext.value }
    }

    func seqIgnoreRight<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<T, Input> {
        var lazyNext = Lazy(next)
        return flatMap { firstResult in
            lazyNext.value.map { _ in
                firstResult
            }
        }
    }
}


infix operator ~: ApplicativePrecedence

func ~ <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                     rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<(T, U), Input> {
    return lhs().seq(rhs())
}

func ~ <T, U, V, Input>(lhs: @autoclosure () -> Parser<(T, U), Input>,
                        rhs: @autoclosure @escaping () -> Parser<V, Input>) -> Parser<(T, U, V), Input> {
    return lhs().seq(rhs()).map { ($0.0.0, $0.0.1, $0.1) }
}

func ~ <T, U, V, W, Input>(lhs: @autoclosure () -> Parser<(T, U, V), Input>,
                           rhs: @autoclosure @escaping () -> Parser<W, Input>) -> Parser<(T, U, V, W), Input> {
    return lhs().seq(rhs()).map { ($0.0.0, $0.0.1, $0.0.2, $0.1) }
}

func ~ <T, U, V, W, X, Input>(lhs: @autoclosure () -> Parser<(T, U, V, W), Input>,
                              rhs: @autoclosure @escaping () -> Parser<X, Input>) -> Parser<(T, U, V, W, X), Input> {
    return lhs().seq(rhs()).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.1) }
}



// NOTE: actual defintition would be, but already defined in the standard definition as a workaround,
// see https://github.com/apple/swift/blob/48308411393e730cf3cb21d353a9be31045c47e4/stdlib/public/core/Policy.swift#L705
//infix operator ~> : ApplicativeSequencePrecedence

func ~> <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                      rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
    return lhs().seqIgnoreLeft(rhs())
}

infix operator <~ : ApplicativeSequencePrecedence

func <~ <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                      rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<T, Input> {
    return lhs().seqIgnoreRight(rhs())
}
