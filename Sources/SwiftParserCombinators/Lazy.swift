
internal class Lazy<T> {
    private let generate: () -> T

    internal lazy var value: T = {
        return self.generate()
    }()

    internal init(_ generate: @escaping () -> T) {
        self.generate = generate
    }
}
