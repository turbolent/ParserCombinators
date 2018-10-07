
extension Parser {

    public static func recursive(_ generate: @escaping (Parser<T, Element>) -> Parser<T, Element>)
        -> Parser<T, Element>
    {
        var p: Parser<T, Element>!

        p = generate(Parser { input in
            p.step(input)
        })

        return p
    }
}
