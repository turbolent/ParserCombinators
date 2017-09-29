
import Trampoline

extension Parser {

    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    public func or<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        let lazyNext = Lazy(next)
        return Parser<U, Input> { input in
            self.step(input).flatMap { result in
                switch result {
                case let .success(value, remaining):
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here.
                    // Furthermore it is not possible in Swift constrain U to be a supertype of T
                    return Done(.success(value: value as! U, remaining: remaining))

                case let .error(message, remaining):
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `self` here.
                    return Done(.error(message: message, remaining: remaining))

                case let .failure(message, remaining):
                    return More { lazyNext.value.step(input) }.map { alt in
                        switch alt {
                        case .success:
                            return alt
                        case .failure(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `self` here
                                return .failure(message: message, remaining: remaining)
                            }
                            return alt
                        case .error(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `self` here
                                return .error(message: message, remaining: remaining)
                            }
                            return alt
                        }
                    }
                }
            }
        }
    }
}


// NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
public func || <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                             rhs: @autoclosure @escaping () -> Parser<U, Input>)
    -> Parser<U, Input>
{
    return lhs().or(rhs())
}

