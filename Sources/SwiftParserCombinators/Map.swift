import Trampoline

extension Parser {
    func map<U>(_ f: @escaping (T) -> U) -> Parser<U, Input> {
        return Parser<U, Input> { input in
            self.step(input).map { $0.map(f) }
        }
    }

    func map<U>(_ value: @autoclosure @escaping () -> U) -> Parser<U, Input> {
        let lazyValue = Lazy(value)
        return Parser<U, Input> { input in
            self.step(input).map { $0.map { _ in lazyValue.value } }
        }
    }

    func flatMap<U>(_ f: @escaping (T) -> Parser<U, Input>) -> Parser<U, Input> {
        return Parser<U, Input> { input in
            self.step(input).flatMap { $0.flatMapWithNext(f) }
        }
    }
}


infix operator ^^ : ApplicativePrecedence

func ^^ <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                      rhs: @escaping (T) -> U) -> Parser<U, Input> {
    return lhs().map(rhs)
}

infix operator ^^^ : ApplicativePrecedence

func ^^^ <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                       rhs: @autoclosure @escaping () -> U) -> Parser<U, Input> {
    return lhs().map(rhs())
}
