//
//  String+index.swift
//  Canyoneer
//
//  Created by Brice Pollock on 2/6/22.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> String {
        String(self[index(startIndex, offsetBy: offset)])
    }
}
