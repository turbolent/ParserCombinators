
import Foundation


public class Reader<Element> {

    internal init() {}

    internal var atEnd: Bool {
        fatalError()
    }

    internal var first: Element {
        fatalError()
    }

    internal func rest() -> Self {
        fatalError()
    }

    internal var position: Position {
        fatalError()
    }

    internal var offset: Int {
        fatalError()
    }
}

extension Reader {
    public func read(count: Int) throws -> ([Element], Reader<Element>) {
        var elements: [Element] = []
        var reader = self
        for _ in 0..<count {
            guard !reader.atEnd else {
                throw ReaderError.endOfFile
            }

            elements.append(reader.first)
            reader = reader.rest()
        }
        return (elements, reader)
    }
}

public enum ReaderError: Error {
    case endOfFile
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

