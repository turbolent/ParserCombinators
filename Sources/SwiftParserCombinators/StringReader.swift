
public struct StringReader: Reader {

    private let characters: String.CharacterView
    private let index: String.CharacterView.Index

    public init(string: String) {
        self.init(characters: string.characters,
                  index: string.characters.startIndex)
    }

    private init(characters: String.CharacterView,
                 index: String.CharacterView.Index)
    {
        self.characters = characters
        self.index = index
    }

    public var atEnd: Bool {
        return index >= characters.endIndex
    }

    public var first: Character {
        return characters[index]
    }

    public var rest: StringReader {
        return StringReader(characters: characters,
                            index: characters.index(after: index))
    }

    public var offset: String.CharacterView.Index {
        return index
    }

    public var position: StringPosition {
        return StringPosition(characters: characters,
                              index: index)
    }
}


public struct StringPosition: Position {
    public let characters: String.CharacterView
    public let index: String.CharacterView.Index

    public var lineContents: String {
        return String(characters)
    }

    public var column: Int {
        return characters.distance(from: characters.startIndex, to: index) + 1
    }
}
