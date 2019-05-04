
import Foundation


public class Reader<Element> {

    internal init() {}

    public var atEnd: Bool {
        fatalError()
    }

    public var first: Element {
        fatalError()
    }

    public func rest() -> Self {
        fatalError()
    }

    public var position: Position {
        fatalError()
    }

    public var offset: Int {
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
    func lineContents(upToColumn: Int?) -> String
}


extension Position {
    public var description: String {
        return String(column)
    }

    public var lineContents: String {
        return lineContents(upToColumn: nil)
    }

    public var longDescription: String {
        let prefix = lineContents(upToColumn: column)
        let space = String(prefix.map { c in c == "\t" ? c : " " })
        return lineContents + "\n\(space)^"
    }
}
