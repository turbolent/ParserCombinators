
import Foundation
import ParserDescription


public struct UnsupportedPatternError: Error {
    public let pattern: _Pattern
}


extension UnsupportedPatternError: LocalizedError {
    public var errorDescription: String? {
        return "Unsupported pattern: \(pattern)"
    }
}


public extension _Pattern {
    func compile<Token>() throws -> Parser<Captures, Token>
        where Token: ParserDescription.Token
    {
        switch self {
        case let pattern as SequencePattern:
            return try pattern.compile()
        case let pattern as OrPattern:
            return try pattern.compile()
        case let pattern as RepetitionPattern:
            return try pattern.compile()
        case let pattern as CapturePattern:
            return try pattern.compile()
        case let pattern as TokenPattern:
            return try pattern.compile()
        case let pattern as AnyPattern:
            return try pattern.compile()
        default:
            throw UnsupportedPatternError(pattern: self)
        }
    }
}


public extension AnyPattern {

    func compile<Token>() throws -> Parser<Captures, Token>
        where Token: ParserDescription.Token
    {
        return try pattern.compile()
    }
}


public extension SequencePattern {

    func compile<Token>() throws -> Parser<Captures, Token>
        where Token: ParserDescription.Token
    {
        return try patterns
            .map { try $0.compile() }
            .reduce(success(Captures.empty)) { $0.seq($1) }
    }
}


public extension OrPattern {

    func compile<Token>() throws -> Parser<Captures, Token>
        where Token: ParserDescription.Token
    {
        return try patterns
            .map { try $0.compile() }
            .reduce(success(Captures.empty)) { $0.or($1) }
    }
}


public extension RepetitionPattern {

    func compile<Token>() throws -> Parser<Captures, Token>
        where Token: ParserDescription.Token
    {
        return try pattern.compile()
            .rep(min: min,
                 max: max)
    }
}


public extension CapturePattern {

    func compile<Token>() throws -> Parser<Captures, Token>
        where Token: ParserDescription.Token
    {
        return try pattern.compile()
            .capture(name)
    }
}


public extension TokenPattern {

    func compile<Token>() throws -> Parser<Captures, Token>
        where Token: ParserDescription.Token
    {
        guard let condition = condition else {
            return accept().captured()
        }

        let predicate = try condition.compile()
        return acceptIf(errorMessageSupplier: { [condition] token in
                            "token \(token) does not match condition \(condition)"
                        },
                        predicate)
            .captured()
    }
}
