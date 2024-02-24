//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

enum TechnicalGrade: Int, CaseIterable, Codable, Equatable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    
    var text: String {
        switch self {
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        }
    }
    
    init?(text: String) {
        guard let found = TechnicalGrade.allCases.first(where: { $0.text == text }) else {
            return nil
        }
        self = found
    }
    
    init?(data: Int?) {
        guard let data else { return nil }
        guard let found = TechnicalGrade(rawValue: data) else {
            return nil
        }
        self = found
    }
}

enum WaterGrade: String, CaseIterable, Codable, Equatable {
    case a = "A"
    case b = "B"
    case c = "C"
    case c1 = "C1"
    case c2 = "C2"
    case c3 = "C3"
    case c4 = "C4"
    
    var text: String {
        self.rawValue
    }
    
    init?(data: String?) {
        guard let data else { return nil }
        guard let found = WaterGrade(rawValue: data) else {
            return nil
        }
        self = found
    }
}

enum TimeGrade: String, CaseIterable, Codable, Equatable {
    case one = "I"
    case two = "II"
    case three = "III"
    case four = "IV"
    case five = "V"
    case six = "VI"
    
    var text: String {
        self.rawValue
    }
    
    var number: Int {
        switch self {
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        }
    }
    
    init?(data: String?) {
        guard let data else { return nil }
        guard let found = TimeGrade(rawValue: data) else {
            return nil
        }
        self = found
    }
}

enum Risk: String, Codable {
    case pg = "PG"
    case pg13 = "PG-13"
    case r = "R"
    case x = "X"
    case xx = "XX"
    case xxx = "XXX"
}
