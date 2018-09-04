
import Trampoline
import Foundation

/// Create a parser that accepts a single input element that satisfies a given predicate,
/// and returns the parsed element.
///
/// - Parameters:
///   - predicate: A function that determines if an input element matches.
///   - errorMessageSupplier: A function which is used to generate the error message for an invalid element.
///   - element: The input element to be tested.
///   - invalidElement: The input element which did not satisfy the predicate.
///
public func acceptIf<Element>(predicate: @escaping (_ element: Element) -> Bool,
                              errorMessageSupplier: @escaping (_ invalidElement: Element) -> String)
    -> Parser<Element, Element>
{
    return Parser { input in
        guard !input.atEnd else {
            return Done(.failure(message: "end of input",
                                 remaining: input))
        }

        let element = input.first

        guard predicate(element) else {
            let message = errorMessageSupplier(element)
            return Done(.failure(message: message,
                                 remaining: input))
        }

        return Done(.success(value: element,
                             remaining: input.rest()))
    }
}

/// Create a parser that accepts a single input element that satisfies a given predicate,
/// and returns the parsed element.
///
/// - Parameters:
///   - kind: The element kind, used for error messages.
///   - predicate: A function that determines if an input element matches.
///
public func elem<Element>(kind: String, predicate: @escaping (Element) -> Bool)
    -> Parser<Element, Element>
    where Element: Equatable
{
    return acceptIf(predicate: predicate,
                    errorMessageSupplier: { e in "\(kind) expected" })
}

/// Create a parser that accepts a single input element and returns the parsed element (i.e. `element`).
///
/// - Parameter element: The input element to be parsed.
///
public func accept<Element>(_ element: Element) -> Parser<Element, Element>
    where Element: Equatable
{
    return acceptIf(predicate: { $0 == element },
                    errorMessageSupplier: { e in "expected \(element) but found \(e)" })
}

/// Create a parser that accepts a single character and returns the parsed character (i.e. `char`).
///
/// - Parameter char: The character to be parsed.
///
public func char(_ char: Character) -> Parser<Character, Character> {
    return accept(char)
}

/// Create a parser that accepts a single character, which must be in the set of valid characters,
/// and returns the parsed character.
///
/// - Parameters:
///   - characters: The set of valid characters.
///   - kind: The element kind, used for error messages.
///
public func `in`(_ characters: CharacterSet, kind: String = "") -> Parser<Character, Character> {
    return elem(kind: kind) {
        !$0.unicodeScalars.contains {
            !characters.contains($0)
        }
    }
}

/// Create a parser that accepts a single character, which must not be in the set of invalid characters,
/// and returns the parsed character.
///
/// - Parameters:
///   - characters: The set of invalid characters.
///   - kind: The element kind, used for error messages.
///
public func notIn(_ characters: CharacterSet, kind: String = "") -> Parser<Character, Character> {
    return elem(kind: kind) {
        !$0.unicodeScalars.contains(where: characters.contains)
    }
}
