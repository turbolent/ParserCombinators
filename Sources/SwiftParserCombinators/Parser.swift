
import Trampoline


struct Parser<T, Input: Reader> {
    typealias Result = ParseResult<T, Input>

    let step: (Input) -> Trampoline<Result>

    init(step: @escaping (Input) -> Trampoline<Result>) {
        self.step = step
    }

    func parse(_ input: Input) -> Result {
        return step(input).run()
    }
}
