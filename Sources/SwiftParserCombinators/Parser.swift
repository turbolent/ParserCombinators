
import Trampoline

public class Parser<T, Element> {
    public typealias Input = Reader<Element>
    public typealias Result = ParseResult<T, Element>

    private let stepFunction: (Input) -> Trampoline<Result>

    public init(_ stepFunction: @escaping (Input) -> Trampoline<Result>) {
        self.stepFunction = stepFunction
    }

    public func step(_ input: Input) -> Trampoline<Result> {
        return stepFunction(input)
    }

    public func parse(_ input: Input) -> Result {
        return step(input).run()
    }
}
