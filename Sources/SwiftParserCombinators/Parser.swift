
// NOTE: could be just `typealias Parser<T, Input: Reader> = (Input) -> ParseResult<T, Input>`
// but wouldn't allow providing chaining methods

class Parser<T, Input: Reader> {
    typealias Result = ParseResult<T, Input>

    let parse: (Input) -> Result

    init(f: @escaping (Input) -> Result) {
        self.parse = f
    }

    func map<U>(_ f: @escaping (T) -> U) -> Parser<U, Input> {
        return Parser<U, Input> { input in
            self.parse(input).map(f)
        }
    }

    func flatMap<U>(_ f: @escaping (T) -> Parser<U, Input>) -> Parser<U, Input> {
        return Parser<U, Input> { input in
            self.parse(input).flatMapWithNext(f)
        }
    }

    func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<(T, U), Input> {
        let lazyNext = Lazy(next)
        return flatMap { firstResult in
            lazyNext.value.map { secondResult in
                (firstResult, secondResult)
            }
        }
    }

    func seqIgnoreLeft<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        let lazyNext = Lazy(next)
        return flatMap { _ in lazyNext.value }
    }

    func seqIgnoreRight<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<T, Input> {
        let lazyNext = Lazy(next)
        return flatMap { firstResult in
            lazyNext.value.map { _ in
                firstResult
            }
        }
    }

    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    func append<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        let lazyNext = Lazy(next)
        return Parser<U, Input> { input in
            self.parse(input).append(lazyNext.value.parse(input))
        }
    }
    
    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    func or<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        return append(next())
    }

    func opt() -> Parser<T?, Input> {
        return SwiftParserCombinators.opt(self)
    }

    func rep(min: Int = 0, max: Int? = nil) -> Parser<[T], Input> {
        return SwiftParserCombinators.rep(self, min: min, max: max)
    }
}

func success<T, Input>(_ value: T) -> Parser<T, Input> {
    return Parser { input in
        .success(value: value, remaining: input)
    }
}

func failure<T, Input>(_ message: String) -> Parser<T, Input> {
    return Parser { input in
        .failure(message: message, remaining: input)
    }
}

func acceptIf<Input>(predicate: @escaping (Input.Element) -> Bool,
                     errorMessageSupplier: @escaping (Input.Element) -> String)
    -> Parser<Input.Element, Input>
{
    return Parser { input in
        guard !input.atEnd else {
            return .failure(message: "end of input", remaining: input)
        }

        let element = input.first

        guard predicate(element) else {
            let message = errorMessageSupplier(element)
            return .failure(message: message, remaining: input)
        }

        return .success(value: element,
                        remaining: input.rest)
    }
}

func accept<Input>(element: Input.Element) -> Parser<Input.Element, Input>
    where Input.Element: Equatable
{
    return acceptIf(predicate: { $0 == element },
                    errorMessageSupplier: { e in "expected \(element) but found \(e)" })
}

func char<Input>(_ char: Character) -> Parser<Character, Input>
    where Input.Element == Character
{
    return accept(element: char)
}

// NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
func | <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                     rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {

    return lhs().or(rhs())
}

precedencegroup AlternativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: ComparisonPrecedence
}

precedencegroup ApplicativePrecedence {
    associativity: left
    higherThan: AlternativePrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator ^^ : ApplicativePrecedence

func ^^ <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                      rhs: @escaping (T) -> U) -> Parser<U, Input> {
    return lhs().map(rhs)
}

infix operator ~: ApplicativePrecedence

func ~ <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                     rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<(T, U), Input> {
    return lhs().seq(rhs())
}

precedencegroup ApplicativeSequencePrecedence {
    associativity: left
    higherThan: ApplicativePrecedence
    lowerThan: NilCoalescingPrecedence
}

// NOTE: actual defintition would be, but already defined in the standard definition as a workaround,
// see https://github.com/apple/swift/blob/48308411393e730cf3cb21d353a9be31045c47e4/stdlib/public/core/Policy.swift#L705
//infix operator ~> : ApplicativeSequencePrecedence

func ~> <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                      rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
    return lhs().seqIgnoreLeft(rhs())
}

infix operator <~ : ApplicativeSequencePrecedence

func <~ <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                      rhs: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<T, Input> {
    return lhs().seqIgnoreRight(rhs())
}

func opt<T, Input>(_ parser: @autoclosure () -> Parser<T, Input>) -> Parser<T?, Input> {
    return parser().map { $0 } | success(nil)
}

func rep<T, Input>(_ parser: @autoclosure @escaping () -> Parser<T, Input>, min: Int = 0, max: Int? = nil)
    -> Parser<[T], Input>
{
    if let max = max, max == 0 {
        return success([])
    }

    return Parser { input in
        let lazyParser = Lazy(parser)

        var remaining = input
        var elements: [T] = []
        var n = 0
        while true {
            if n == max {
                return .success(value: elements, remaining: remaining)
            }

            let result = lazyParser.value.parse(remaining)
            switch result {
            case .success(let value, let rest):
                elements.append(value)
                n += 1
                remaining = rest
            case .failure(let message, let remaining2):
                guard n >= min else {
                    // NOTE: unfortunately Swift doesn't have a bottom type, so can't use `result` here.
                    return .failure(message: message, remaining: remaining2)
                }
                return .success(value: elements, remaining: remaining)
            }
        }
    }
}
