
import Trampoline

public func endOfInput<Element>() -> Parser<Unit, Element> {
    return Parser { input in
        guard input.atEnd else {
            return Done(.failure(
                message: "End of input expected",
                remaining: input
            ))
        }
        return Done(.success(
            value: .empty,
            remaining: input
        ))
    }
}
