
protocol Reader {
    associatedtype Element
    associatedtype Offset: Comparable
    associatedtype Pos: Position
    var atEnd: Bool { get }
    var first: Element { get }
    var rest: Self { get }
    var offset: Offset { get }
    var position: Pos { get }
}

protocol Position: CustomStringConvertible  {
    var column: Int { get }
    var lineContents: String { get }
}

extension Position {
    var description: String {
        return String(column)
    }

    var longDescription: String {
        let prefix = lineContents.prefix(column)
        let space = String(prefix.map { c in c == "\t" ? c : " " })
        return lineContents + "\n\(space)^"
    }
}

