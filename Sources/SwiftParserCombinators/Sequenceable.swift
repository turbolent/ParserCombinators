
public protocol Sequenceable {
    associatedtype SelfSequenced
    associatedtype PreviousSequenced
    associatedtype NextSequenced

    associatedtype Previous
    associatedtype Next

    func sequence(other: Self) -> SelfSequenced
    func sequence(previous: Previous) -> PreviousSequenced
    func sequence(next: Next) -> NextSequenced
}


extension Array: Sequenceable {

    public func sequence(other: [Element]) -> [Element] {
        var result = self
        result.append(contentsOf: other)
        return result
    }

    public func sequence(next: Element) -> [Element] {
        var result = self
        result.append(next)
        return result
    }

    public func sequence(previous: Element) -> [Element] {
        var result = [previous]
        result.append(contentsOf: self)
        return result
    }
}

public protocol AnySequenceable {
    associatedtype SelfSequenced
    associatedtype PreviousAnySequenced
    associatedtype NextAnySequenced

    func sequence(other: Self) -> SelfSequenced
    func sequence(previous: Any) -> PreviousAnySequenced
    func sequence(next: Any) -> NextAnySequenced

}
