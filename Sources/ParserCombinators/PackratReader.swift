
import Trampoline


public final class PackratReader<Element>: Reader<Element> {

    // boxed, so that entries can be shared
    private final class Cache {
        fileprivate var entries: [CacheKey: ParseResult<Any, Element>] = [:]
    }

    public let underlying: Reader<Element>

    private var cache: Cache

    public convenience init(underlying: Reader<Element>) {
        self.init(underlying: underlying,
                  cache: Cache())
    }

    private init(underlying: Reader<Element>,
                 cache: Cache) {
        self.underlying = underlying
        self.cache = cache
    }

    public override var atEnd: Bool {
        return underlying.atEnd
    }

    public override var first: Element {
        return underlying.first
    }

    public override var offset: Int {
        return underlying.offset
    }

    public override var position: Position {
        return underlying.position
    }

    public override func rest() -> PackratReader<Element> {
        return PackratReader(underlying: underlying.rest(),
                             cache: cache)
    }

    fileprivate func getFromCache<T>(parser: Parser<T, Element>) -> ParseResult<T, Element>? {
        let key = CacheKey(parser: parser, offset: offset)
        guard let result = cache.entries[key] else {
            return nil
        }
        return result.map { $0 as! T }
    }

    fileprivate func updateCacheAndGet<T>(parser: Parser<T, Element>,
                                          result: ParseResult<T, Element>)
        -> ParseResult<T, Element>
    {
        let key = CacheKey(parser: parser, offset: offset)
        cache.entries[key] = result.map { $0 as Any }
        return result
    }
}

fileprivate struct CacheKey: Hashable {

    let parserIdentifier: ObjectIdentifier
    let offset: Int

    init<U, Element>(parser: Parser<U, Element>, offset: Int) {
        self.parserIdentifier = ObjectIdentifier(parser)
        self.offset = offset
    }
}

public class PackratParser<T, Element>: Parser<T, Element> {

    public init(parser: @autoclosure @escaping () -> Parser<T, Element>) {
        let lazyParser = Lazy(parser)

        super.init { input in

            guard let packratReader = input as? PackratReader<Element> else {
                return lazyParser.value.step(input)
            }

            if let result = packratReader.getFromCache(parser: lazyParser.value) {
                return Done(result)
            }

            let error: ParseResult<T, Element> =
                .error(message: "left-recursion", remaining: input)
            _ = packratReader.updateCacheAndGet(parser: lazyParser.value,
                                                result: error)

            return lazyParser.value.step(packratReader).map {
                packratReader.updateCacheAndGet(parser: lazyParser.value,
                                                result: $0)
            }
        }
    }
}
