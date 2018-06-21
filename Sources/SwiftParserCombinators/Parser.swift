
import Trampoline


public class Parser<T, Element> {
    public typealias Input = Reader<Element>
    public typealias Result = ParseResult<T, Element>

    private let stepFunction: (Input) -> Trampoline<Result>

    public init(_ stepFunction: @escaping (Input) -> Trampoline<Result>) {
        self.stepFunction = stepFunction
    }

    public func step<Input>(_ input: Input) -> Trampoline<Result> where Input: Reader<Element> {
        return stepFunction(input)
    }

    public func parse<Input>(_ input: Input) -> Result where Input: Reader<Element> {
        return step(input).run()
    }
}
