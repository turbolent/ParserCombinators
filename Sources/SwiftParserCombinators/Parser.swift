
// NOTE: could be just `typealias Parser<T, Input: Reader> = (Input) -> ParseResult<T, Input>`
// but wouldn't allow providing chaining methods

struct Parser<T, Input: Reader> {
    typealias Result = ParseResult<T, Input>

    let parse: (Input) -> Result

    init(parse: @escaping (Input) -> Result) {
        self.parse = parse
    }
}
