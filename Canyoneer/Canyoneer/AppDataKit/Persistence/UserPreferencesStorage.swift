//
//  DiskStorage.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/11/22.
//

import Foundation

class UserPreferencesStorage: Storage {
    private var cache = [String: Any]()
    private let lock = NSLock()
    
    public static let shared = UserPreferencesStorage()
    
    static func clearAll() {
        self.clearFavorites()
    }
    
    internal init() {}
    
    public func set<T: Codable>(key: String, value: T) {
        lock.lock()
        guard let data = try? JSONEncoder().encode(value) else {
            Global.logger.error("Unable to encode value as data for \(key)")
            lock.unlock()
            return
        }
        UserDefaults.standard.set(data, forKey: key)
        lock.unlock()
    }
    
    public func get<T: Codable>(key: String) -> T? {
        lock.lock()
        
        guard let data = UserDefaults.standard.data(forKey: key) else {
            lock.unlock()
            return nil
        }
        let value = try? JSONDecoder().decode(T.self, from: data)
        lock.unlock()
        
        guard let stored = value else {
            Global.logger.debug("Cannot find value in persistence for key \(key)")
            return nil
        }
        return stored
    }
    
    public func remove(key: String) {
        lock.lock()
        UserDefaults.standard.removeObject(forKey: key)
        lock.unlock()
    }
    
    public func all<T: Codable>() -> [T] {
        lock.lock()
        let values = UserDefaults.standard.dictionaryRepresentation().values
        lock.unlock()
        return values.compactMap {
            $0 as? T
        }
    }
    
    public func clear() {
        lock.lock()
        UserDefaults.resetStandardUserDefaults()
        lock.unlock()
    }
}
