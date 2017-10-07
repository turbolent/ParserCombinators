
import Foundation


public protocol Reader {
    associatedtype Element
    associatedtype Offset: Comparable
    associatedtype Position: SwiftParserCombinators.Position
    var atEnd: Bool { get }
    var first: Element { get }
    var rest: Self { get }
    var offset: Offset { get }
    var position: Position { get }
}

public enum ReaderError: Error {
    case endOfFile
}


extension Reader {
    public func read(count: Int) throws -> ([Element], Self) {
        var elements: [Element] = []
        var reader = self
        for _ in 0..<count {
            guard !reader.atEnd else {
                throw ReaderError.endOfFile
            }

            elements.append(reader.first)
            reader = reader.rest
        }
        return (elements, reader)
    }
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
        let prefix = lineContents.prefix(column)
        let space = String(prefix.map { c in c == "\t" ? c : " " })
        return lineContents + "\n\(space)^"
    }
}

