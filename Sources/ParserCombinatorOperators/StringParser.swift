
import ParserCombinators


// ||

public func || (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) || StringParser(rhs)
}

public func || (lhs: Parser<String, Character>, rhs: String) -> Parser<String, Character> {
    return lhs || StringParser(rhs)
}

public func || (
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<String, Character>
)
    -> Parser<String, Character>
{
    return StringParser(lhs) || rhs()
}

public func || <T>(
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<T, Character>
)
    -> Parser<Either<String, T>, Character>
{
    return StringParser(lhs) || rhs()
}


// |||

public func ||| (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) ||| StringParser(rhs)
}

public func ||| (lhs: Parser<String, Character>, rhs: String) -> Parser<String, Character> {
    return lhs ||| StringParser(rhs)
}

public func ||| (
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<String, Character>
)
    -> Parser<String, Character>
{
    return StringParser(lhs) ||| rhs()
}

public func ||| <T>(
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<T, Character>
)
    -> Parser<Either<String, T>, Character>
{
    return StringParser(lhs) ||| rhs()
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

public func ~ <T>(
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<T, Character>
)
    -> Parser<(String, T), Character>
{
    return StringParser(lhs) ~ rhs()
}

public func ~ (
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<String, Character>
)
    -> Parser<[String], Character>
{
    return StringParser(lhs) ~ rhs()
}

public func ~ (
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<[String], Character>
)
    -> Parser<[String], Character>
{
    return StringParser(lhs) ~ rhs()
}



// ~>

public func ~> (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) ~> StringParser(rhs)
}

public func ~> (lhs: Parser<String, Character>, rhs: String) -> Parser<String, Character> {
    return lhs ~> StringParser(rhs)
}

public func ~> <T>(
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<T, Character>
)
    -> Parser<T, Character>
{
    return StringParser(lhs) ~> rhs()
}


// <~

public func <~ (lhs: String, rhs: String) -> Parser<String, Character> {
    return StringParser(lhs) <~ StringParser(rhs)
}

public func <~ <T>(lhs: Parser<T, Character>, rhs: String) -> Parser<T, Character> {
    return lhs <~ StringParser(rhs)
}

public func <~ <T>(
    lhs: String,
    rhs: @autoclosure @escaping () -> Parser<T, Character>
)
    -> Parser<String, Character>
{
    return StringParser(lhs) <~ rhs()
}


// ^^

public func ^^ <T>(
    lhs: String,
    rhs: @escaping (String) throws -> T
)
    -> Parser<T, Character>
{
    return StringParser(lhs).map(rhs)
}


// ^^^

public func ^^^ <T>(
    lhs: String,
    rhs: @autoclosure @escaping () -> T
)
    -> Parser<T, Character>
{
    return StringParser(lhs).map(rhs())
}
