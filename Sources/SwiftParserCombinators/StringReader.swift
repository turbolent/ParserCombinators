
public struct StringReader: Reader {
    private let string: String
    private let index: String.Index

    public init(string: String) {
        self.init(string: string,
                  index: string.startIndex)
    }

    private init(string: String,
                 index: String.Index)
    {
        self.string = string
        self.index = index
    }

    public var atEnd: Bool {
        return index >= string.endIndex
    }

    public var first: Character {
        return string[index]
    }

    public var rest: StringReader {
        return StringReader(string: string,
                            index: string.index(after: index))
    }

    public var offset: String.Index {
        return index
    }

    public var position: StringPosition {
        return StringPosition(string: string,
                              index: index)
    }
}

public struct StringPosition: Position {
    public let string: String
    public let index: String.Index

    public var lineContents: String {
        return string
    }

    public var column: Int {
        return string.distance(from: string.startIndex, to: index) + 1
    }
}
