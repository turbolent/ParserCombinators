//
//extension Parser {
//
//    func rep(min: Int = 0, max: Int? = nil) -> Parser<[T], Input> {
//        return SwiftParserCombinators.rep(self, min: min, max: max)
//    }
//}
//
//
//func rep<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>, min: Int = 0, max: Int? = nil)
//    -> Parser<[T], Input>
//{
//    if let max = max, max == 0 {
//        return success([])
//    }
//
//    return Parser { input in
//        var lazyParser = Lazy(parser)
//
//        var remaining = input
//        var elements: [T] = []
//        var n = 0
//        while true {
//            if n == max {
//                return .success(value: elements, remaining: remaining)
//            }
//
//            let result = lazyParser.value.parse(remaining)
//            switch result {
//            case let .success(value, rest):
//                elements.append(value)
//                n += 1
//                remaining = rest
//            case let .failure(message2, remaining2):
//                guard n >= min else {
//                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
//                    return .failure(message: message2, remaining: remaining2)
//                }
//                return .success(value: elements, remaining: remaining)
//            case let .error(message2, remaining2):
//                guard n >= min else {
//                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
//                    return .error(message: message2, remaining: remaining2)
//                }
//                return .success(value: elements, remaining: remaining)
//            }
//        }
//    }
//}

