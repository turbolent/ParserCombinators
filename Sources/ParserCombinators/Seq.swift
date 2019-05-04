
extension Parser {

    private func seq<U, V>(
        _ next: Lazy<Parser<U, Element>>,
        f: @escaping (T, U) -> V) -> Parser<V, Element>
    {
        return flatMap { firstResult in
            next.value.map { secondResult in
                f(firstResult, secondResult)
            }
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both in a tuple.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<(T, U), Element>
    {
        return seqTuple(next())
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both in a tuple.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seqTuple<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<(T, U), Element>
    {
        return seq(Lazy(next)) { ($0, $1) }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both sequenced.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<U, Element>
        where U: Sequenceable, U.Element == T
    {
        return seq(Lazy(next)) {
            U.empty
                .sequence(next: $0)
                .sequence(next: $1)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both sequenced.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<U, Element>
        where U: Sequenceable, U.Element == T
    {
        return seq(Lazy(next)) {
            // NOTE: order
            $1.sequence(previous: $0)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both sequenced.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<U, Element>
        where U: AnySequenceable
    {
        return seq(Lazy(next)) {
            // NOTE: order
            $1.sequence(previous: $0)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the result of the next parser, i.e., the result of this parser is ignored.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seqIgnoreLeft<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<U, Element>
    {
        let lazyNext = Lazy(next)
        return flatMap { _ in lazyNext.value }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the result of this parser, i.e., the result of the next parser is ignored.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seqIgnoreRight<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) { (left, _) in left }
    }
}

extension Parser where T: Sequenceable {

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both sequenced.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq(_ next: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) {
            $0.sequence(other: $1)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both sequenced.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<T, Element>
        where T.Element == U
    {
        return seq(Lazy(next)) {
            $0.sequence(next: $1)
        }
    }
}

extension Parser where T: AnySequenceable {

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both sequenced.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq(_ next: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) {
            $0.sequence(other: $1)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence,
    /// and returns the results of both sequenced.
    /// The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) {
            $0.sequence(next: $1)
        }
    }
}

