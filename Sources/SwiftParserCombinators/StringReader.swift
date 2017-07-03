
struct StringReader: Reader {

    let characters: String.CharacterView
    let index: String.CharacterView.Index

    init(string: String) {
        self.init(characters: string.characters,
                  index: string.characters.startIndex)
    }

    init(characters: String.CharacterView,
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

    var pos: String.CharacterView.Index {
        return index
    }
}

