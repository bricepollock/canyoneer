//  Created by Brice Pollock for Canyoneer on 3/24/24

import Foundation
import MapboxMaps

extension Canyon: PossibleIdentifable {
     var lookupID: String? { id }
}

extension CanyonIndex: PossibleIdentifable {
    var lookupID: String? { id }
}

extension PointAnnotation: PossibleIdentifable {
    var lookupID: String? { canyonId }
}

extension PolylineAnnotation: PossibleIdentifable {
    var lookupID: String? { canyonId }
}

protocol PossibleIdentifable {
    var lookupID: String? { get }
}

struct ComparisonLookup<T: PossibleIdentifable, V: PossibleIdentifable> {
    let added: [String: T]
    let removed: [String: V]
    let matched: [String: T]

    /// Add the two together
    let merged: [String: String]

    /// Should match NEW
    var updateFromNew: [T] {
        Array(added.values) + Array(matched.values)
    }
}

extension Array where Element: PossibleIdentifable {
    func compare<V: PossibleIdentifable>(to existing: [V]) -> ComparisonLookup<Element, V> {
        var newMap = [String: Element]()
        self.forEach {
            guard let id = $0.lookupID else {
                return
            }
            newMap[id] = $0
        }

        var merged = [String: String]()
        var removed = [String: V]()
        var added = [String: Element]()
        var matched = [String: Element]()

        existing
            .forEach {
                guard let id = $0.lookupID else {
                    return
                }
                if newMap[id] == nil {
                    removed[id] = $0
                }
                merged[id] = id
            }

        self.forEach {
            guard let id = $0.lookupID else {
                return
            }
            if merged[id] == nil {
                added[id] = $0
            } else {
                matched[id] = $0
            }
            merged[id] = id
        }
        return ComparisonLookup(added: added, removed: removed, matched: matched, merged: merged)
    }
}

struct ComparisonLookupIDs {
    let added: [String: String]
    let removed: [String: String]
    let matched: [String: String]
    
    /// Add the two together
    let merged: [String: String]
    
    /// Should match NEW
    var updateFromNew: [String] {
        Array(added.values) + Array(matched.values)
    }
}


func compare(newIDs: [String], existingIDs: [String]) -> ComparisonLookupIDs {
    var updatedMap = [String: String]()
    newIDs.forEach { updatedMap[$0] = $0}
    
    var merged = [String: String]()
    var removed = [String: String]()
    var added = [String: String]()
    var matched = [String: String]()
    
    existingIDs
        .forEach {
            if updatedMap[$0] == nil {
                removed[$0] = $0
            }
            merged[$0] = $0
        }
    
    newIDs.forEach {
        if merged[$0] == nil {
            added[$0] = $0
        } else {
            matched[$0] = $0
        }
        merged[$0] = $0
    }
    return ComparisonLookupIDs(added: added, removed: removed, matched: matched, merged: merged)
}
