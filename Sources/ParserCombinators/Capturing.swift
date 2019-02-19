
public struct Captures {
    public typealias Values = [Any]
    public typealias Entries = [String: [Values]]

    public let values: Values
    public fileprivate(set) var entries: Entries = [:]

    public init(values: Values, entries: Entries) {
        self.values = values
        self.entries = entries
    }

    public init() {
        self.init(values: [], entries: [:])
    }

    public init(value: Any) {
        self.init(values: [value], entries: [:])
    }

    fileprivate func with(name: String, values: Values) -> Captures {
        var result = self
        if result.entries[name] != nil {
            result.entries[name]?.append(values)
        } else {
            let entries = [values]
            result.entries[name] = entries
        }
        return result
    }
}

extension Parser {

    public func capture(_ name: String) -> Parser<Captures, Element> {
        return map { Captures(values: [$0], entries: [name: [[$0]]]) }
    }
}

extension Parser where T == Captures {

    public func capture(_ name: String) -> Parser<Captures, Element> {
        return map { $0.with(name: name, values: $0.values) }
    }
}

extension Captures: AnySequenceable {

    public static var empty: Captures {
        return Captures()
    }

    public func sequence(other: Captures) -> Captures {
        var values = self.values
        values.append(contentsOf: other.values)
        var entries = self.entries
        for (name, otherValues) in other.entries {
            if entries[name] != nil {
                entries[name]?.append(contentsOf: otherValues)
            } else {
                entries[name] = otherValues
            }
        }
        return Captures(values: values, entries: entries)
    }

    public func sequence(previous: Any) -> Captures {
        // NOTE: sequencing important, otherwise entries get lost
        if let other = previous as? Captures {
            return sequence(other: other)
        } else {
            var values = [previous]
            values.append(contentsOf: self.values)
            return Captures(values: values, entries: entries)
        }
    }

    public func sequence(next: Any) -> Captures {
        // NOTE: sequencing important, otherwise entries get lost
        if let other = next as? Captures {
            return sequence(other: other)
        } else {
            var values = self.values
            values.append(next)
            return Captures(values: values, entries: entries)
        }
    }
}
