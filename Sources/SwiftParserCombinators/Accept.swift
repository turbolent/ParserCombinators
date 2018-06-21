
import Trampoline


public func acceptIf<Element>(predicate: @escaping (Element) -> Bool,
                              errorMessageSupplier: @escaping (Element) -> String)
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

public func elem<Element>(kind: String, predicate: @escaping (Element) -> Bool)
    -> Parser<Element, Element>
    where Element: Equatable
{
    return acceptIf(predicate: predicate,
                    errorMessageSupplier: { e in "\(kind) expected" })
}

public func accept<Element>(_ element: Element) -> Parser<Element, Element>
    where Element: Equatable
{
    return acceptIf(predicate: { $0 == element },
                    errorMessageSupplier: { e in "expected \(element) but found \(e)" })
}

public func char(_ char: Character) -> Parser<Character, Character> {
    return accept(char)
}
