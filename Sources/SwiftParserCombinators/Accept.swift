
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

public func elem<Input>(kind: String, predicate: @escaping (Input.Element) -> Bool)
    -> Parser<Input.Element, Input>
    where Input.Element: Equatable
{
    return acceptIf(predicate: predicate,
                    errorMessageSupplier: { e in "\(kind) expected" })
}

public func accept<Input>(_ element: Input.Element) -> Parser<Input.Element, Input>
    where Input.Element: Equatable
{
    return acceptIf(predicate: { $0 == element },
                    errorMessageSupplier: { e in "expected \(element) but found \(e)" })
}

public func char<Input>(_ char: Character) -> Parser<Character, Input>
    where Input.Element == Character
{
    return accept(char)
}

public func literal<Input>(_ string: String) -> Parser<String, Input>
    where Input.Element == Character
{
    let count = string.distance(from: string.startIndex, to: string.endIndex)

    return Parser { input in
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
