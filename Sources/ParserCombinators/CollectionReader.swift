
public class CollectionReader<C: Collection>: Reader<C.Element> {
    private let collection: C
    private let index: C.Index

    public convenience init(collection: C) {
        self.init(collection: collection,
                  index: collection.startIndex)
    }

    public init(collection: C,
                index: C.Index)
    {
        self.collection = collection
        self.index = index
        super.init()
    }

    public override var atEnd: Bool {
        return index >= collection.endIndex
    }

    public override var first: C.Element {
        return collection[index]
    }

    public override func rest() -> CollectionReader<C> {
        return CollectionReader(collection: collection,
                                index: collection.index(after: index))
    }

    public override var position: Position {
        return CollectionPosition(collection: collection,
                                  index: index)
    }

    public override var offset: Int {
        return collection.distance(from: collection.startIndex, to: index)
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
