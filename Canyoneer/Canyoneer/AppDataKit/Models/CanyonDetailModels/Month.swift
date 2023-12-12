//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

enum Month: String, Codable, CaseIterable, Equatable {
    case january = "January"
    case february = "Feburary"
    case march = "March"
    case april = "April"
    case may = "May"
    case june = "June"
    case july = "July"
    case august = "August"
    case september = "September"
    case october = "October"
    case november = "November"
    case december = "December"
    
    init?(short: String) {
        if let result =  Self.allCases.filter({ $0.short == short }).first {
            self = result
        } else {
            return nil
        }
    }
    
    var initial: String {
        return String(self.rawValue.prefix(1))
    }
    
    var short: String {
        return String(self.rawValue.prefix(3))
    }
}
