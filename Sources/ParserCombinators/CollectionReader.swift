
open class CollectionReader<C>: Reader<C.Element>
    where C: Collection
{
    public let collection: C
    public let index: C.Index

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

    open override var atEnd: Bool {
        return index >= collection.endIndex
    }

    open override var first: C.Element {
        return collection[index]
    }

    open override func rest() -> Self {
        return type(of: self).init(
            collection: collection,
            index: collection.index(after: index)
        )
    }

    open override var position: Position {
        return CollectionPosition(
            collection: collection,
            index: index
        )
    }

    open override var offset: Int {
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
