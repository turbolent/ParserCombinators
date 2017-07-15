
struct Lazy<T> {
    let generate: () -> T
    lazy var value: T = {
        return self.generate()
    }()

    init(_ generate: @escaping () -> T) {
        self.generate = generate
    }
}
