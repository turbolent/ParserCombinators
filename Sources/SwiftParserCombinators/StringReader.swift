
struct StringReader: Reader {

    private let characters: String.CharacterView
    private let index: String.CharacterView.Index

    init(string: String) {
        self.init(characters: string.characters,
                  index: string.characters.startIndex)
    }

    private init(characters: String.CharacterView,
         index: String.CharacterView.Index)
    {
        self.characters = characters
        self.index = index
    }

    var atEnd: Bool {
        return index >= characters.endIndex
    }

    var first: Character {
        return characters[index]
    }

    var rest: StringReader {
        return StringReader(characters: characters,
                            index: characters.index(after: index))
    }

    var offset: String.CharacterView.Index {
        return index
    }

    var position: StringPosition {
        return StringPosition(characters: characters,
                              index: index)
    }
}


struct StringPosition: Position {
    let characters: String.CharacterView
    let index: String.CharacterView.Index

    var lineContents: String {
        return String(characters)
    }

    var column: Int {
        return characters.distance(from: characters.startIndex, to: index) + 1
    }
}

