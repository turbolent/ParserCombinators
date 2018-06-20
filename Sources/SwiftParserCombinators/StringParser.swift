
import Trampoline


public final class StringParser<Input: Reader>: Parser<String, Input>, ExpressibleByStringLiteral
    where Input.Element == Character
{
    public convenience init(stringLiteral string: String) {
        self.init(string)
    }

    public init(_ string: String) {
        let count = string.distance(from: string.startIndex, to: string.endIndex)

        super.init { input in
            do {
                let (elements, remaining) = try input.read(count: count)
                let parsed = String(elements)
                guard parsed == string else {
                    return Done(.failure(message: "expected \(string) but found \(parsed)", remaining: input))
                }
                return Done(.success(value: string, remaining: remaining))
            } catch ReaderError.endOfFile {
                return Done(.failure(message: "reached end-of-file", remaining: input))
            } catch let e {
                return Done(.failure(message: "unexpexted error \(e)", remaining: input))
            }
        }
    }
}

public func literal<Input>(_ string: String) -> StringParser<Input>
    where Input.Element == Character
{
    return StringParser(string)
}

public func opt<Input>(_ string: String) -> Parser<String?, Input>
    where Input.Element == Character
{
    return StringParser(string).opt()
}


// ||

public func || <Input>(lhs: String, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return StringParser(lhs) || StringParser(rhs)
}

public func || <Input>(lhs: Parser<String, Input>, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return lhs || StringParser(rhs)
}

public func || <Input>(lhs: String,
                       rhs: @autoclosure @escaping () -> Parser<String, Input>)
    -> Parser<String, Input>
    where Input.Element == Character
{
    return StringParser(lhs) || rhs
}

public func || <T, Input>(lhs: String,
                          rhs: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<Either<String, T>, Input>
    where Input.Element == Character
{
    return StringParser(lhs) || rhs
}


// |||

public func ||| <Input>(lhs: String, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return StringParser(lhs) ||| StringParser(rhs)
}

public func ||| <Input>(lhs: Parser<String, Input>, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return lhs ||| StringParser(rhs)
}

public func ||| <Input>(lhs: String,
                        rhs: @autoclosure @escaping () -> Parser<String, Input>)
    -> Parser<String, Input>
    where Input.Element == Character
{
    return StringParser(lhs) ||| rhs
}

public func ||| <T, Input>(lhs: String,
                           rhs: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<Either<String, T>, Input>
    where Input.Element == Character
{
    return StringParser(lhs) ||| rhs
}


// ~

public func ~ <Input>(lhs: String, rhs: String) -> Parser<[String], Input>
    where Input.Element == Character {

    return StringParser(lhs) ~ StringParser(rhs)
}

public func ~ <Input>(lhs: Parser<String, Input>, rhs: String) -> Parser<[String], Input>
    where Input.Element == Character {

    return lhs ~ StringParser(rhs)
}

public func ~ <T, Input>(lhs: String,
                         rhs: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<(String, T), Input>
    where Input.Element == Character {

    return StringParser(lhs) ~ rhs
}

public func ~ <Input>(lhs: Parser<[String], Input>, rhs: String) -> Parser<[String], Input>
    where Input.Element == Character {

    return lhs ~ StringParser(rhs)
}


// ~>

public func ~> <Input>(lhs: String, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return StringParser(lhs) ~> StringParser(rhs)
}

public func ~> <Input>(lhs: Parser<String, Input>, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return lhs ~> StringParser(rhs)
}

public func ~> <T, Input>(lhs: String,
                          rhs: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<T, Input>
    where Input.Element == Character
{
    return StringParser(lhs) ~> rhs
}


// <~

public func <~ <Input>(lhs: String, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return StringParser(lhs) <~ StringParser(rhs)
}

public func <~ <Input>(lhs: Parser<String, Input>, rhs: String) -> Parser<String, Input>
    where Input.Element == Character
{
    return lhs <~ StringParser(rhs)
}

public func <~ <T, Input>(lhs: String,
                          rhs: @autoclosure @escaping () -> Parser<T, Input>)
    -> Parser<String, Input>
    where Input.Element == Character
{
    return StringParser(lhs) <~ rhs
}


// ^^

public func ^^ <T, Input>(lhs: String,
                          rhs: @escaping (String) throws -> T)
    -> Parser<T, Input>
    where Input.Element == Character {

    return StringParser(lhs).map(rhs)
}


// ^^^

public func ^^^ <T, Input>(lhs: String,
                           rhs: @autoclosure @escaping () -> T)
    -> Parser<T, Input>
    where Input.Element == Character {

    return StringParser(lhs).map(rhs)
}
