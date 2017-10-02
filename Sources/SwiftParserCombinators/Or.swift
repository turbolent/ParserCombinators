
import Trampoline

extension Parser {

    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    public func or<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        let lazyNext = Lazy(next)
        return Parser<U, Input> { input in
            self.step(input).flatMap { result in
                switch result {
                case let .success(value, remaining):
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
                    // Furthermore it is not possible in Swift to constrain type U to be a supertype of T
                    return Done(.success(value: value as! U, remaining: remaining))

                case let .error(message, remaining):
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
                    return Done(.error(message: message, remaining: remaining))

                case let .failure(message, remaining):
                    return More { lazyNext.value.step(input) }.map { altResult in
                        switch altResult {
                        case .success:
                            return altResult

                        case .failure(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `result` here
                                return .failure(message: message, remaining: remaining)
                            }
                            return altResult

                        case .error(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `result` here
                                return .error(message: message, remaining: remaining)
                            }
                            return altResult
                        }
                    }
                }
            }
        }
    }

    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    public func orLonger<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        let lazyNext = Lazy(next)
        return Parser<U, Input> { input in
            self.step(input).flatMap { result in
                switch result {
                case let .success(value, remaining):
                    return More { lazyNext.value.step(input) }.map { altResult in
                        switch altResult {
                        case .success(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `result` here.
                                // Furthermore it is not possible in Swift to constrain
                                // type U to be a supertype of T
                                return .success(value: value as! U, remaining: remaining)
                            }
                            return altResult

                        case .failure, .error:
                            // NOTE: unfortunately Swift doesn't have a bottom type,
                            // so can't use `result` here.
                            // Furthermore it is not possible in Swift to constrain
                            // type U to be a supertype of T
                            return .success(value: value as! U, remaining: remaining)
                        }
                    }

                case let .error(message, remaining):
                    return Done(.error(message: message, remaining: remaining))

                case let .failure(message, remaining):
                    return More { lazyNext.value.step(input) }.map { altResult in
                        switch altResult {
                        case .success:
                            return altResult

                        // NOTE: unfortunately matching a generic value in multiple patterns
                        // is not yet supported, so can't bind `remaining` here
                        case .failure, .error:
                            if altResult.remaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `result` here.
                                return .failure(message: message, remaining: remaining)
                            }
                            return altResult
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
    return lhs().or(rhs)
}


infix operator ||| : LogicalDisjunctionPrecedence

// NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
public func ||| <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                              rhs: @autoclosure @escaping () -> Parser<U, Input>)
    -> Parser<U, Input>
{
    return lhs().orLonger(rhs)
}


