
import Trampoline


public func acceptIf<Input>(predicate: @escaping (Input.Element) -> Bool,
                            errorMessageSupplier: @escaping (Input.Element) -> String)
    -> Parser<Input.Element, Input>
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
                             remaining: input.rest))
    }
}

public func accept<Input>(element: Input.Element) -> Parser<Input.Element, Input>
    where Input.Element: Equatable
{
    return acceptIf(predicate: { $0 == element },
                    errorMessageSupplier: { e in "expected \(element) but found \(e)" })
}

public func char<Input>(_ char: Character) -> Parser<Character, Input>
    where Input.Element == Character
{
    return accept(element: char)
}
