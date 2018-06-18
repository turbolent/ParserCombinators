
import Trampoline


public class Parser<T, Input: Reader> {
    public typealias Result = ParseResult<T, Input>

    public let step: (Input) -> Trampoline<Result>

    public init(step: @escaping (Input) -> Trampoline<Result>) {
        self.step = step
    }

    public func parse(_ input: Input) -> Result {
        return step(input).run()
    }
}
