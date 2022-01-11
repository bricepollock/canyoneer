//
//  Storage.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/11/22.
//

import Foundation

protocol Storage {
    static func clearAll()
    
    // All methods should be thread safe
    func set<T: Codable>(key: String, value: T)
    func get<T: Codable>(key: String) -> T?
    func remove(key: String)
    func all<T: Codable>() -> [T]
    func clear()
}
