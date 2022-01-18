//
//  DispatchTime+duration.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation

extension DispatchTime {
    static func minutes(_ value: TimeInterval) -> DispatchTime {
        return seconds(value * 60)
    }
    
    static func seconds(_ value: TimeInterval) -> DispatchTime {
        return DispatchTime.now() + value
    }
}
