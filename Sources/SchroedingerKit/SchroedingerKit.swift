import Foundation

func mkgrams(s: String, depth: Int = 6) -> Set<String> {
    var gs = Set<String>()
    let norm = Array(s.decomposedStringWithCanonicalMapping.unicodeScalars)
    let len = norm.count
    let rdepth = min(len, depth)
    for i in 0..<len {
        var accum = ""
        for j in 0..<rdepth {
            guard (i + j < len) else { break }
            accum += String(norm[i + j])
            gs.insert(accum)
        }
    }
    return gs
}

func boundWrap(s: String) -> String {
    "\u{2}" + s + "\u{3}"
}

public protocol FullTextQueriable {
    associatedtype Ident: Hashable
    func query(query: String) -> Array<Ident>
    func queryBounded(query: String) -> Array<Ident>
}

public protocol FullTextIndex: FullTextQueriable {
    mutating func insert(k: Ident, index_string: String)
    mutating func insertBounded(k: Ident, index_string: String)
    mutating func removeK(k: Ident)
}

public struct FullTextInvertIndex<Ident: Hashable>: FullTextIndex {
    let depth: Int
    var index = Dictionary<String, Set<Ident>>()

    init(index: Dictionary<String, Set<Ident>> = Dictionary<String, Set<Ident>>(), depth: Int = 6) {
        self.depth = depth
        self.index = index
    }

    public func query(query: String) -> Array<Ident> {
        let gs = mkgrams(s: query, depth: depth)
        var accum_map = Dictionary<Ident, Int>()

        for g in gs {
            index[g]?.forEach { k in
                accum_map[k] = (accum_map[k] ?? 0) + 1
            }
        }
        return accum_map
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }

    public func queryBounded(query: String) -> Array<Ident> {
        self.query(query: boundWrap(s: query))
    }

    public mutating func insert(k: Ident, index_string: String) {
        let gs = mkgrams(s: index_string, depth: depth)
        for g in gs {
            index[g] = index[g, default: .init()].union([k])
        }
    }

    public mutating func insertBounded(k: Ident, index_string: String) {
        self.insert(k: k, index_string: boundWrap(s: index_string))
    }

    public mutating func removeK(k: Ident) {
        for (g, v) in index {
            self.index[g] = v.subtracting([k])
        }
    }

    public func toMerge() -> FullTextMergeIndex<Ident> {
        var new = Dictionary<Ident, Set<String>>()

        for (g, ks) in index {
            for k in ks {
                new[k] = new[k, default: .init()].union([g])
            }
        }

        return FullTextMergeIndex<Ident>(index: new, depth: depth)
    }

}

public struct FullTextMergeIndex<Ident: Hashable>: FullTextIndex {
    let depth: Int
    var index: Dictionary<Ident, Set<String>>

    init(index: Dictionary<Ident, Set<String>> = .init(), depth: Int = 6) {
        self.depth = depth
        self.index = index
    }

    public func query(query: String) -> [Ident] {
        let gs = mkgrams(s: query, depth: depth)
        return index
            .map { key, value in
                (key, gs.intersection(value).count)
            }
            .filter { $0.1 != 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    public func queryBounded(query: String) -> [Ident] {
        self.query(query: boundWrap(s: query))
    }

    public mutating func insert(k: Ident, index_string: String) {
        let gs = mkgrams(s: index_string, depth: depth)
        index[k] = index[k, default: .init()].union(gs)
    }

    public mutating func insertBounded(k: Ident, index_string: String) {
        insert(k: k, index_string: boundWrap(s: index_string))
    }

    public mutating func removeK(k: Ident) {
        index.removeValue(forKey: k)
    }

    public func toInvert() -> FullTextInvertIndex<Ident> {
        var new = Dictionary<String, Set<Ident>>()
        for (k, gs) in index {
            for g in gs {
                new[g] = new[g, default: .init()].union([k])
            }
        }
        return FullTextInvertIndex<Ident>(index: new, depth: depth)
    }

}
