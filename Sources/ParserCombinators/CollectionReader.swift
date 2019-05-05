
open class CollectionReader<C>: Reader<C.Element>
    where C: Collection
{
    private let collection: C
    private let index: C.Index

    public required init(collection: C, index: C.Index) {
        self.collection = collection
        self.index = index
        super.init()
    }

    public convenience init(collection: C) {
        self.init(
            collection: collection,
            index: collection.startIndex
        )
    }

    public override var atEnd: Bool {
        return index >= collection.endIndex
    }

    public override var first: C.Element {
        return collection[index]
    }

    public override func rest() -> Self {
        return type(of: self).init(
            collection: collection,
            index: collection.index(after: index)
        )
    }

    public override var position: Position {
        return CollectionPosition(
            collection: collection,
            index: index
        )
    }

    public override var offset: Int {
        return collection.distance(
            from: collection.startIndex,
            to: index
        )
    }
}


public struct CollectionPosition<C>: Position
    where C: Collection
{
    public func lineContents(upToColumn column: Int?) -> String {
        if let column = column {
            return collection
                .prefix(column - 1)
                .map { String(describing: $0) + " " }
                .joined()

        } else {
            return collection
                .map { String(describing: $0) }
                .joined(separator: " ")
        }
    }

    public let collection: C
    public let index: C.Index

    public init(collection: C, index: C.Index) {
        self.collection = collection
        self.index = index
    }

    public var column: Int {
        return collection.distance(from: collection.startIndex, to: index) + 1
    }
}
