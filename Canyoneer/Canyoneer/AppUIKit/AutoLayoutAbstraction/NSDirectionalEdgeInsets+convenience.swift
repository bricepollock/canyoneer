//
//  NSLayoutOffsets+convenience.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

/// Convenience method for common directional inset values
extension NSDirectionalEdgeInsets {
    public init(all: CGFloat) {
        self.init(top: all, leading: all, bottom: -all, trailing: -all)
    }
    
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: -vertical, trailing: -horizontal)
    }
}
