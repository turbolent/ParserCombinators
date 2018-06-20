
public struct CollectionReader<C: Collection>: Reader {
    private let collection: C
    private let index: C.Index

    public init(collection: C) {
        self.init(collection: collection,
                  index: collection.startIndex)
    }

    public init(collection: C,
                index: C.Index)
    {
        self.collection = collection
        self.index = index
    }

    public var atEnd: Bool {
        return index >= collection.endIndex
    }

    public var first: C.Element {
        return collection[index]
    }

    public var rest: CollectionReader<C> {
        return CollectionReader(collection: collection,
                                index: collection.index(after: index))
    }

    public var offset: C.Index {
        return index
    }

    public var position: CollectionPosition<C> {
        return CollectionPosition(collection: collection,
                                  index: index)
    }
}

public struct CollectionPosition<C: Collection>: Position {
    public let collection: C
    public let index: C.Index

    public var lineContents: String {
        return collection.map { String(describing: $0) }.joined()
    }

    public var column: Int {
        return collection.distance(from: collection.startIndex, to: index) + 1
    }
}
