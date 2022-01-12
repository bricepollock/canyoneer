//
//  Logger+error.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import OSLog

extension Logger {
    func error(_ error: Error) {
        self.error("\(String(describing: error))")
    }
}
