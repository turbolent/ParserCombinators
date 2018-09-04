
public protocol Sequenceable {
    associatedtype SelfSequenced
    associatedtype PreviousSequenced
    associatedtype NextSequenced

    associatedtype Previous
    associatedtype Next

    static var empty: Self { get }

    func sequence(other: Self) -> SelfSequenced
    func sequence(previous: Previous) -> PreviousSequenced
    func sequence(next: Next) -> NextSequenced
}


public struct Unit {
    public static let empty = Unit()
    private init() {}
}


extension Unit: Sequenceable {

    public func sequence(other: Unit) -> Unit {
        return .empty
    }

    public func sequence(previous: Unit) -> Unit {
        return .empty
    }

    public func sequence(next: Unit) -> Unit {
        return .empty
    }
}

extension Array: Sequenceable {

    public static var empty: Array<Element> {
        return []
    }

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
