//
//  Storage.swift
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation



// In Memory Cache
//  - Require T: Any be T: Codable
//  - Abstract Storage into a Storable interface applied to InMemory and Disk storages
class InMemoryStorage: Storage {
    private var cache = [String: Any]()
    private let lock = NSLock()
    
    public static let canyons = InMemoryStorage()
    
    static func clearAll() {
        // no cached items yet
    }
    
    private init() {}
    
    public func set<T: Codable>(key: String, value: T) {
        lock.lock()
        cache[key] = value
        lock.unlock()
    }
    
    public func get<T: Codable>(key: String) -> T? {
        lock.lock()
        let value = cache[key]
        lock.unlock()
        
        guard let stored = value else {
            return nil
        }
        return stored as? T
    }
    
    public func remove(key: String) {
        lock.lock()
        cache[key] = nil
        lock.unlock()
    }
    
    public func all<T: Codable>() -> [T] {
        lock.lock()
        let values = cache.values
        lock.unlock()
        return values.compactMap {
            $0 as? T
        }
    }
    
    public func clear() {
        lock.lock()
        self.cache = [String: Any]()
        lock.unlock()
    }
}
