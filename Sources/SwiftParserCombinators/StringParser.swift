
import Trampoline
import Foundation


public final class StringParser: Parser<String, Character>, ExpressibleByStringLiteral {

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

public func literal(_ string: String) -> StringParser {
    return StringParser(string)
}

public func opt(_ string: String) -> Parser<String?, Character> {
    return StringParser(string).opt()
}


// ||

public func || (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) || StringParser(rhs)
}

public func || (lhs: Parser<String, Character>, rhs: String) -> Parser<String, Character> {
    return lhs || StringParser(rhs)
}

public func || (lhs: String,
                rhs: @autoclosure @escaping () -> Parser<String, Character>)
    -> Parser<String, Character>
{
    return StringParser(lhs) || rhs
}

public func || <T>(lhs: String,
                   rhs: @autoclosure @escaping () -> Parser<T, Character>)
    -> Parser<Either<String, T>, Character>
{
    return StringParser(lhs) || rhs
}


// |||

public func ||| (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) ||| StringParser(rhs)
}

public func ||| (lhs: Parser<String, Character>, rhs: String) -> Parser<String, Character> {
    return lhs ||| StringParser(rhs)
}

public func ||| (lhs: String,
                 rhs: @autoclosure @escaping () -> Parser<String, Character>)
    -> Parser<String, Character>
{
    return StringParser(lhs) ||| rhs
}

public func ||| <T>(lhs: String,
                    rhs: @autoclosure @escaping () -> Parser<T, Character>)
    -> Parser<Either<String, T>, Character>
{
    return StringParser(lhs) ||| rhs
}


// ~

public func ~ (lhs: String, rhs: String) -> Parser<[String], Character> {
    return StringParser(lhs) ~ StringParser(rhs)
}

public func ~ <T>(lhs: Parser<T, Character>, rhs: String) -> Parser<(T, String), Character> {
    return lhs ~ StringParser(rhs)
}

public func ~ (lhs: Parser<String, Character>, rhs: String) -> Parser<[String], Character> {
    return lhs ~ StringParser(rhs)
}

public func ~ (lhs: Parser<[String], Character>, rhs: String) -> Parser<[String], Character> {
    return lhs ~ StringParser(rhs)
}

public func ~ <T>(lhs: String,
                  rhs: @autoclosure @escaping () -> Parser<T, Character>)
    -> Parser<(String, T), Character>
{
    return StringParser(lhs) ~ rhs
}

public func ~ (lhs: String,
               rhs: @autoclosure @escaping () -> Parser<String, Character>)
    -> Parser<[String], Character>
{
    return StringParser(lhs) ~ rhs
}

public func ~ (lhs: String,
               rhs: @autoclosure @escaping () -> Parser<[String], Character>)
    -> Parser<[String], Character>
{
    return StringParser(lhs) ~ rhs
}



// ~>

public func ~> (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) ~> StringParser(rhs)
}

public func ~> (lhs: Parser<String, Character>, rhs: String) -> Parser<String, Character> {
    return lhs ~> StringParser(rhs)
}

public func ~> <T>(lhs: String,
                   rhs: @autoclosure @escaping () -> Parser<T, Character>)
    -> Parser<T, Character>
{
    return StringParser(lhs) ~> rhs
}


// <~

public func <~ (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) <~ StringParser(rhs)
}

public func <~ <T>(lhs: Parser<T, Character>, rhs: String) -> Parser<T, Character> {
    return lhs <~ StringParser(rhs)
}

public func <~ <T>(lhs: String,
                   rhs: @autoclosure @escaping () -> Parser<T, Character>)
    -> Parser<String, Character>
{
    return StringParser(lhs) <~ rhs
}


// ^^

public func ^^ <T>(lhs: String,
                   rhs: @escaping (String) throws -> T)
    -> Parser<T, Character>
{
    return StringParser(lhs).map(rhs)
}


// ^^^

public func ^^^ <T>(lhs: String,
                    rhs: @autoclosure @escaping () -> T)
    -> Parser<T, Character>
{
    return StringParser(lhs).map(rhs)
}

public func withWhitespace<T>(_ parser: Parser<T, Character>) -> Parser<T, Character> {
    return (whitespace ~> parser) <~ whitespace
}

public let whitespace: Parser<Unit, Character> =
    (`in`([" ", "\t", "\r", "\n"], kind: "whitespace") ^^^ Unit.empty).rep()
