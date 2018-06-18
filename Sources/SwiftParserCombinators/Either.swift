
public enum Either<T, U> {
    case left(T)
    case right(U)
}

extension Either where T == U {
    public var value: T {
        switch self {
        case .left(let value):
            return value
        case .right(let value):
            return value
        }
    }
}
