//
//  UnitConverter.swift
//  whereToClimb
//
//  Created by Brice Pollock on 3/2/19.
//  Copyright © 2019 Brice Pollock. All rights reserved.
//

import Foundation

struct UnitConverter {
    
    static func mToFt(_ mm: Double) -> Double {
        return mm * 3.28
    }
    
    static func msToMph(_ mm: Double) -> Double {
        return mm * 2.237
    }
    
    static func mmToInch(_ mm: Double) -> Double {
        return mm * 0.0393701
    }
    
    static func celciusToF(_ degrees: Double) -> Double {
        return (degrees * 9 / 5) + 32
    }
}
