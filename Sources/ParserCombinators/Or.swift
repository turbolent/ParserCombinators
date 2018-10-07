
import Trampoline

extension Parser {

    /// Creates a new parser that succeeds if (and only if) either when this parser succeeds,
    /// or if this parser fails, when the alternative parser succeeds.
    ///
    /// - Note: The alternative parser is only tried if this parser's failure is non-fatal,
    ///         i.e. not an error, and so backtracking is allowed.
    ///
    /// - Parameter alternative: A parser that will be applied if this parser fails.
    ///
    public func or<U>(_ alternative: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<Either<T, U>, Element>
    {
        let lazyAlternative = Lazy(alternative)
        return Parser<Either<T, U>, Element> { input in
            self.step(input).flatMap { result in
                switch result {
                case .success:
                    return Done(result.map { .left($0) })

                case let .error(message, remaining):
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
                    return Done(.error(message: message, remaining: remaining))

                case let .failure(message, remaining):
                    return More { lazyAlternative.value.step(input) }.map { altResult in
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

    /// Creates a new parser that succeeds if (and only if) either when this parser succeeds,
    /// or if this parser fails, when the alternative parser succeeds.
    ///
    /// - Note: The alternative parser is only tried if this parser's failure is non-fatal,
    ///         i.e. not an error, and so backtracking is allowed.
    ///
    /// - Parameter alternative: A parser that will be applied if this parser fails.
    ///
    public func or(_ alternative: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<T, Element>
    {
        return or(alternative).map { $0.value }
    }

    /// Creates a new parser that succeeds if this parser or the alternative parser succeeds.
    /// If both parsers succeed, the result of the new parser is the result of the parser
    /// that consumed the most elements.
    ///
    /// - Note: The alternative parser is only tried if this parser's failure is non-fatal,
    ///         i.e. not an error, and so backtracking is allowed.
    ///
    /// - Parameter alternative: A parser that will be applied if this parser fails.
    ///
    public func orLonger<U>(_ alternative: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<Either<T, U>, Element>
    {
        let lazyAlternative = Lazy(alternative)
        return Parser<Either<T, U>, Element> { input in
            self.step(input).flatMap { result in
                switch result {
                case .success(_, let remaining):
                    return More { lazyAlternative.value.step(input) }.map { altResult in
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
                    return More { lazyAlternative.value.step(input) }.map { altResult in
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

    /// Creates a new parser that succeeds if this parser or the alternative parser succeeds.
    /// If both parsers succeed, the result of the new parser is the result of the parser
    /// that consumed the most elements.
    ///
    /// - Note: The alternative parser is only tried if this parser's failure is non-fatal,
    ///         i.e. not an error, and so backtracking is allowed.
    ///
    /// - Parameter alternative: A parser that will be applied if this parser fails.
    ///
    public func orLonger(_ alternative: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<T, Element>
    {
        return orLonger(alternative).map { $0.value }
    }
}


/// Creates a new parser that succeeds if (and only if) either when the first parser succeeds,
/// or if it fails, when the alternative parser succeeds.
///
/// - Note: The alternative parser is only tried if the first parser's failure is non-fatal,
///         i.e. not an error, and so backtracking is allowed.
///
/// - Parameters:
///   - first: A parser that will be applied first.
///   - alternative: A parser that will be applied if the first parser fails.
///
public func || <T, U, Element>(first: Parser<T, Element>,
                               alternative: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<Either<T, U>, Element>
{
    return first.or(alternative)
}

/// Creates a new parser that succeeds if (and only if) either when the first parser succeeds,
/// or if it fails, when the alternative parser succeeds.
///
/// - Note: The alternative parser is only tried if the first parser's failure is non-fatal,
///         i.e. not an error, and so backtracking is allowed.
///
/// - Parameters:
///   - first: A parser that will be applied first.
///   - alternative: A parser that will be applied if the first parser fails.
///
public func || <T, Element>(first: Parser<T, Element>,
                            alternative: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    return first.or(alternative)
}


infix operator ||| : LogicalDisjunctionPrecedence

/// Creates a new parser that succeeds if the first parser or the alternative parser succeeds.
/// If both parsers succeed, the result of the new parser is the result of the parser
/// that consumed the most elements.
///
/// - Note: The alternative parser is only tried if the first parser's failure is non-fatal,
///         i.e. not an error, and so backtracking is allowed.
///
/// - Parameters:
///   - first: A parser that will be applied first.
///   - alternative: A parser that will be applied if the first parser fails.
///
public func ||| <T, U, Element>(first: Parser<T, Element>,
                                alternative: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<Either<T, U>, Element>
{
    return first.orLonger(alternative)
}

/// Creates a new parser that succeeds if the first parser or the alternative parser succeeds.
/// If both parsers succeed, the result of the new parser is the result of the parser
/// that consumed the most elements.
///
/// - Note: The alternative parser is only tried if the first parser's failure is non-fatal,
///         i.e. not an error, and so backtracking is allowed.
///
/// - Parameters:
///   - first: A parser that will be applied first.
///   - alternative: A parser that will be applied if the first parser fails.
///
public func ||| <T, Element>(first: Parser<T, Element>,
                             alternative: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    return first.orLonger(alternative)
}
