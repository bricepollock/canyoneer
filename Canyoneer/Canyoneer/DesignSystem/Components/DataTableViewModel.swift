//  Created by Brice Pollock for Canyoneer on 12/3/23

import Foundation
import SwiftUI

@MainActor
struct DataTableViewModel {
    struct Row: Identifiable {
        var id: String {
            title
        }
        let title: String
        let value: String
        let background: Color
    }
    let rows: [Row]
}

extension DataTableViewModel {
    struct RowData {
        let title: String
        let value: String
    }
    init(canyon: Canyon) {
        let isMetric = Locale.current.measurementSystem != .us
        let longestRapString: String?
        if let longestRap = canyon.maxRapLength?.converted(to: isMetric ? .meters : .feet) {
            let value = Int(longestRap.value.rounded())
            longestRapString = "\(value) \(longestRap.unit.symbol)"
        } else {
            longestRapString = nil
        }
        let dataList = [
            RowData(title: Strings.numRaps, value: Strings.stringValue(string: canyon.numRappelsAsString)),
            RowData(title: Strings.longestRap, value: Strings.stringValue(string: longestRapString)),
            RowData(title: Strings.difficulty, value: Strings.stringValue(string: canyon.technicalDifficulty?.text)),
            RowData(title: Strings.risk, value: Strings.stringValue(string: canyon.risk?.rawValue)),
            RowData(title: Strings.water, value: Strings.stringValue(string: canyon.waterDifficulty?.text)),
            RowData(title: Strings.time, value: Strings.stringValue(string: canyon.timeGrade?.text)),
            RowData(title: Strings.restricted, value: Strings.boolValue(bool: canyon.isRestricted)),
            RowData(title: Strings.permits, value: Strings.boolValue(bool: canyon.requiresPermits)),
            RowData(title: Strings.shuttle, value: Strings.boolValue(bool: canyon.requiresShuttle)),
            RowData(title: Strings.vehicle, value: Strings.stringValue(string: canyon.vehicleAccessibility?.rawValue))
        ]
        rows = dataList.enumerated().map { index, rowData in
            let backgroundColor = index % 2 == 0 ? ColorPalette.GrayScale.white : ColorPalette.GrayScale.light
            return Row(title: rowData.title, value: rowData.value, background: backgroundColor)
        }
    }
    internal enum Strings {
        static func intValue(int: Int?) -> String {
            guard let int = int else { return "--" }
            return String(int)
        }
        static func boolValue(bool: Bool?) -> String {
            guard let bool = bool else { return "--" }
            return bool ? "Yes" : "No"
        }
        static func stringValue(string: String?) -> String {
            guard let string = string else { return "--" }
            return string
        }
        
        // Table Keys
        static let numRaps = "Number Rappels"
        static let longestRap = "Longest Rappel"
        static let restricted = "Has Restrictions"
        static let permits = "Requires Permits"
        static let shuttle = CommonStrings.canyonShuttleRequirementTitle
        static let difficulty = CommonStrings.technicalGradeTitle
        static let risk = "Additional Risk"
        static let water = CommonStrings.waterGradeTitle
        static let time = CommonStrings.timeGradeTitle
        static let quality = "Stars"
        static let vehicle = "Vehicle"
    }
}
