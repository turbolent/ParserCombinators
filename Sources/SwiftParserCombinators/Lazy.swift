
public class Lazy<T> {
    private let generate: () -> T

    public lazy var value: T = {
        return self.generate()
    }()

    public init(_ generate: @escaping () -> T) {
        self.generate = generate
    }
}
