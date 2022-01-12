//
//  Array+safe.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < self.count else {
            return nil
        }
        return self[index]
    }
}
