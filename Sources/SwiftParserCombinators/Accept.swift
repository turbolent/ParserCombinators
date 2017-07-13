
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
