
extension Parser {

    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    func append<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        let lazyNext = Lazy(next)
        return Parser<U, Input> { input in
            self.parse(input).append(lazyNext.value.parse(input))
        }
    }

    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    func or<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        return append(next())
    }
}



// NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
func | <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                     rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {

    return lhs().or(rhs())
}

