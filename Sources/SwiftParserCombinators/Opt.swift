
extension Parser {

    /// Creates a new parser that optionally parses what this parser parses.
    /// The new parser always succeeds. If this parser fails, the new parser returns `nil`.
    public func opt() -> Parser<T?, Element> {
        return SwiftParserCombinators.opt(self)
    }
}


/// Creates a new parser that optionally parses what the given parser parses.
/// The new parser always succeeds. If the given parser fails, the new parser returns `nil`.
///
/// - Parameter parser: The parser to be applied.
///
public func opt<T, Element>(_ parser: Parser<T, Element>) -> Parser<T?, Element> {
    return (parser.map { $0 } || success(nil))
        .map { $0.value }
}
