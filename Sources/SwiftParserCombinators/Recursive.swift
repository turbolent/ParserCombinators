//
//extension Parser {
//
//    static func recursive(_ generate: @escaping (Parser<T, Input>) -> Parser<T, Input>) -> Parser<T, Input> {
//        var p: Parser<T, Input>!
//
//        p = generate(Parser { input in
//            p.parse(input)
//        })
//
//        return p
//    }
//}
//
