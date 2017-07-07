
extension Parser {

    static func recursive(_ generate: @escaping (Parser<T, Input>) -> Parser<T, Input>) -> Parser<T, Input> {
        let rec = RecursiveParser(generate)
        return Parser { rec.parse($0) }
    }
}


private class RecursiveParser<T, Input: Reader> {
    private let generate: (RecursiveParser) -> (Input) -> ParseResult<T, Input>

    private(set) lazy var parse: (Input) -> ParseResult<T, Input> = self.generate(self)

    init(_ generate: @escaping (Parser<T, Input>) -> Parser<T, Input>) {
        self.generate = { rec in
            let parser = Parser { [unowned rec] in rec.parse($0) }
            return generate(parser).parse
        }
    }
}
