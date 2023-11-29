//
//  TopoLineType.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import SwiftUI

enum TopoLineType: String, CaseIterable, Equatable {
    case driving
    case approach
    case descent
    case exit
    case unknown
    
    init(string: String?) {
        guard let string = string else { self = .unknown; return }
        
        if string.lowercased().contains("approach") {
            self = .approach
        } else if string.lowercased().contains("drive") || string.lowercased().contains("shuttle") {
            self = .driving
        } else if string.lowercased().contains("descent") {
            self = .descent
        } else if string.lowercased().contains("exit") {
            self = .exit
        } else {
            self = .unknown
        }
    }
    
    var color: Color {
        switch self {
        case .driving: return ColorPalette.Color.action
        case .approach: return ColorPalette.Color.green
        case .descent: return ColorPalette.Color.warning
        case .exit: return ColorPalette.Color.yellow
        case .unknown: return ColorPalette.GrayScale.dark
        }
    }
}

