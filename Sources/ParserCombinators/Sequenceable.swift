
public protocol Sequenceable {
    associatedtype Element

    static var empty: Self { get }

    func sequence(other: Self) -> Self
    func sequence(previous: Element) -> Self
    func sequence(next: Element) -> Self
}


public struct Unit: Equatable {
    public static let empty = Unit()
    private init() {}
}


extension Unit: AnySequenceable {

    public func sequence(other: Unit) -> Unit {
        return .empty
    }

    public func sequence(previous: Any) -> Unit {
        return .empty
    }

    public func sequence(next: Any) -> Unit {
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
    static var empty: Self { get }

    func sequence(other: Self) -> Self
    func sequence(previous: Any) -> Self
    func sequence(next: Any) -> Self
}
