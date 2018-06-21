
extension Parser {

    public func opt() -> Parser<T?, Element> {
        return SwiftParserCombinators.opt(self)
    }
}


public func opt<T, Element>(_ parser: Parser<T, Element>) -> Parser<T?, Element> {
    return (parser.map { $0 } || success(nil))
        .map { $0.value }
}
