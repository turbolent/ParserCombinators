
extension Parser {

    func opt() -> Parser<T?, Input> {
        return SwiftParserCombinators.opt(self)
    }
}

func opt<T, Input>(_ parser: @autoclosure () -> Parser<T, Input>) -> Parser<T?, Input> {
    return parser().map { $0 } | success(nil)
}
