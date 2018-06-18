
extension Parser {

    public func opt() -> Parser<T?, Input> {
        return SwiftParserCombinators.opt(self)
    }
}


public func opt<T, Input>(_ parser: Parser<T, Input>) -> Parser<T?, Input> {
    return (parser.map { $0 } || success(nil)).map { $0.value }
}
