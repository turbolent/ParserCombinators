
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
                    return Done(.failure(message:
                        "expected \(string) but found \(parsed)", remaining: input)
                    )
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



public func withWhitespace<T>(_ parser: Parser<T, Character>) -> Parser<T, Character> {
    return whitespace
        .seqIgnoreLeft(parser)
        .seqIgnoreRight(whitespace)
}

private let whitespaceCharacterSet: CharacterSet = [" ", "\t", "\r", "\n"]

public let whitespaceCharacter: Parser<Character, Character> =
    `in`(whitespaceCharacterSet, kind: "whitespace")

public let whitespace: Parser<Unit, Character> =
    whitespaceCharacter.map(Unit.empty).rep()
