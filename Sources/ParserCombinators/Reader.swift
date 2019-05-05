
import Foundation


open class Reader<Element> {

    internal init() {}

    open var atEnd: Bool {
        fatalError()
    }

    open var first: Element {
        fatalError()
    }

    open func rest() -> Self {
        fatalError()
    }

    open var position: Position {
        fatalError()
    }

    open var offset: Int {
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
