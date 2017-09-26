
import Foundation


public protocol Reader {
    associatedtype Element
    associatedtype Offset: Comparable
    associatedtype Pos: Position
    var atEnd: Bool { get }
    var first: Element { get }
    var rest: Self { get }
    var offset: Offset { get }
    var position: Pos { get }
}


public protocol Position: CustomStringConvertible  {
    var column: Int { get }
    var lineContents: String { get }
}


extension Position {
    public var description: String {
        return String(column)
    }

    public var longDescription: String {
        // TODO: replace with simpler version once >=4.0 
        // let prefix = lineContents.prefix(column)
        // let space = String(prefix.map { c in c == "\t" ? c : " " })
        
        let line = lineContents
        let index = line.index(line.startIndex, offsetBy: column)
        let prefix = line.substring(to: index)        
        let space = String(prefix.characters.map { c in c == "\t" ? c : " " })

        return lineContents + "\n\(space)^"
    }
}

