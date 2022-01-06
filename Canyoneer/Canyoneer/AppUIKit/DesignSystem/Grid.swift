//
//  Grid.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

enum Grid {
    static let xSmall: CGFloat = 4.0
    static let small: CGFloat = 8.0
    static let medium: CGFloat = 16.0
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 36
}

extension CGFloat {
    static let xSmall = Grid.xSmall
    static let small = Grid.small
    static let medium = Grid.medium
    static let large = Grid.large
    static let xLarge = Grid.xLarge
}
