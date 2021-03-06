
import Trampoline
import Foundation

/// Create a parser that accept any input element and returns the parsed element.
public func accept<Element>() -> Parser<Element, Element> {
    return Parser { input in
        guard !input.atEnd else {
            return Done(.failure(message: "end of input",
                                 remaining: input))
        }

        let element = input.first

        return Done(.success(value: element,
                             remaining: input.rest()))
    }
}

extension Parser {

    /// Creates a parser that succeeds if the given parser succeeds and the result value
    /// satisfies the given predicate. Returns the result value.
    ///
    /// - Parameters:
    ///   - errorMessageSupplier:
    ///       A function which is used to generate the error message for an invalid value.
    ///   - invalidValue:
    ///       The result value which did not satisfy the predicate.
    ///   - predicate:
    ///       A function that determines if the result value matches.
    ///   - value:
    ///       The result value to be tested.
    ///
    public func filter(
        errorMessageSupplier: ((_ invalidValue: T) -> String)? = nil,
        _ predicate: @escaping (_ value: T) -> Bool
    )
        -> Parser<T, Element>
    {
        return map { value in

            guard predicate(value) else {
                let message = errorMessageSupplier?(value)
                    ?? "Value did not match predicate: \(value)"
                throw MapError.failure(message)
            }

            return value
        }
    }
}

/// Create a parser that accepts a single input element that satisfies the given predicate,
/// and returns the parsed element.
///
/// - Parameters:
///   - errorMessageSupplier:
///       A function which is used to generate the error message for an invalid element.
///   - invalidElement:
///       The input element which did not satisfy the predicate.
///   - predicate:
///       A function that determines if the input element matches.
///   - element:
///       The input element to be tested.
///
public func acceptIf<Element>(
    errorMessageSupplier: @escaping (_ invalidElement: Element) -> String,
    _ predicate: @escaping (_ element: Element) -> Bool
)
    -> Parser<Element, Element>
{
    return accept()
        .filter(errorMessageSupplier: errorMessageSupplier,
                predicate)
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
    return acceptIf(errorMessageSupplier: { e in "\(kind) expected" },
                    predicate)
}

/// Create a parser that accepts a single input element
/// and returns the parsed element (i.e. `element`).
///
/// - Parameter element: The input element to be parsed.
///
public func accept<Element>(_ element: Element) -> Parser<Element, Element>
    where Element: Equatable
{
    return acceptIf(errorMessageSupplier: { e in "expected \(element) but found \(e)" }) {
        $0 == element
    }
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

/// Create a parser that accepts a single character, which must not be
/// in the set of invalid characters, and returns the parsed character.
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
