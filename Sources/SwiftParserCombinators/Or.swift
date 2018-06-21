
import Trampoline

extension Parser {

    public func or<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>) -> Parser<Either<T, U>, Element> {
        let lazyNext = Lazy(next)
        return Parser<Either<T, U>, Element> { input in
            self.step(input).flatMap { result in
                switch result {
                case .success:
                    return Done(result.map { .left($0) })

                case let .error(message, remaining):
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
                    return Done(.error(message: message, remaining: remaining))

                case let .failure(message, remaining):
                    return More { lazyNext.value.step(input) }.map { altResult in
                        switch altResult {
                        case .success:
                            return altResult.map { .right($0) }

                        case .failure(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `result` here
                                return .failure(message: message, remaining: remaining)
                            }
                            return altResult.map { .right($0) }

                        case .error(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `result` here
                                return .error(message: message, remaining: remaining)
                            }
                            return altResult.map { .right($0) }
                        }
                    }
                }
            }
        }
    }

    public func or(_ next: @autoclosure @escaping () -> Parser<T, Element>) -> Parser<T, Element> {
        return or(next).map { $0.value }
    }

    public func orLonger<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<Either<T, U>, Element> {

        let lazyNext = Lazy(next)
        return Parser<Either<T, U>, Element> { input in
            self.step(input).flatMap { result in
                switch result {
                case .success(_, let remaining):
                    return More { lazyNext.value.step(input) }.map { altResult in
                        switch altResult {
                        case .success(_, let altRemaining):
                            if altRemaining.offset < remaining.offset {
                                return result.map { .left($0) }
                            }
                            return altResult.map { .right($0) }

                        case .failure, .error:
                            return result.map { .left($0) }
                        }
                    }

                case let .error(message, remaining):
                    return Done(.error(message: message, remaining: remaining))

                case let .failure(message, remaining):
                    return More { lazyNext.value.step(input) }.map { altResult in
                        switch altResult {
                        case .success:
                            return altResult.map { .right($0) }

                        // NOTE: unfortunately matching a generic value in multiple patterns
                        // is not yet supported, so can't bind `remaining` here
                        case .failure, .error:
                            if altResult.remaining.offset < remaining.offset {
                                // NOTE: unfortunately Swift doesn't have a bottom type,
                                // so can't use `result` here.
                                return .failure(message: message, remaining: remaining)
                            }
                            return altResult.map { .right($0) }
                        }
                    }
                }
            }
        }
    }

    public func orLonger(_ next: @autoclosure @escaping () -> Parser<T, Element>) -> Parser<T, Element> {
        return orLonger(next).map { $0.value }
    }
}


public func || <T, U, Element>(lhs: Parser<T, Element>,
                               rhs: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<Either<T, U>, Element>
{
    return lhs.or(rhs)
}

public func || <T, Element>(lhs: Parser<T, Element>,
                            rhs: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    return lhs.or(rhs)
}


infix operator ||| : LogicalDisjunctionPrecedence

public func ||| <T, U, Element>(lhs: Parser<T, Element>,
                                rhs: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<Either<T, U>, Element>
{
    return lhs.orLonger(rhs)
}

public func ||| <T, Element>(lhs: Parser<T, Element>,
                             rhs: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    return lhs.orLonger(rhs)
}

