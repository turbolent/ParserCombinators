
protocol Reader {
    associatedtype Element
    associatedtype Pos: Comparable
    var atEnd: Bool { get }
    var first: Element { get }
    var rest: Self { get }
    var pos: Pos { get }
}
