//
//  CanyonDetailView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class CanyonDetailView: UIView {
    
    enum Strings {
        
        static func summary(for canyon: Canyon) -> String {
            return " Summary: \(Strings.stars(quality: canyon.quality))"
        }
        
        static let details = " Details"
        
        static func summaryDetails(for canyon: Canyon) -> String {
            var summary = ""
            
            if let difficulty = canyon.technicalDifficulty, let water = canyon.waterDifficulty {
                summary.append(" \(difficulty)\(water)")
            } else if let difficulty = canyon.technicalDifficulty {
                summary.append(" \(difficulty)")
            } else if let water = canyon.waterDifficulty {
                summary.append(" \(water)")
            }
            if let time = canyon.timeGrade {
                summary.append(" \(time)")
            }
            if let num = canyon.numRaps {
                summary.append(" \(num)r")
            }
            if let max = canyon.maxRapLength {
                summary.append(" ↧\(max)ft")
            }
            return summary
        }
        
        // data table strings
        static let numRaps = "Number Rappels"
        static let longestRap = "Longest Rappel"
        static let restricted = "Has Restrictions"
        static let permits = "Requires Permits"
        static let shuttle = "Shuttle Required"
        static let difficulty = "Difficulty Rating"
        // these tabs are for alignment in the table, this is a hack-hack shortcut
        static let water = "Water Rating\t"
        static let time = "Time Grade\t"
        static let quality = "Stars"
        static let vehicle = "Vehicle"
        
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
        static func stars(quality: Float) -> String {
            if quality >= 5 {
                return "⭐️⭐️⭐️⭐️⭐️"
            } else if quality >= 4 {
                return "⭐️⭐️⭐️⭐️"
            } else if quality >= 3 {
                return "⭐️⭐️⭐️"
            } else if quality >= 2 {
                return "⭐️⭐️"
            } else {
                return "⭐️"
            }
        }
    }
    
    private let masterStackView = UIStackView()
    private let summaryTitle = UILabel()
    private let summaryDetails = UILabel()
    private let dataTitle = UILabel()
    private let dataTable = DataTableView()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium
        
        self.masterStackView.addArrangedSubview(self.summaryTitle)
        self.masterStackView.addArrangedSubview(self.summaryDetails)
        self.masterStackView.addArrangedSubview(self.dataTitle)
        self.masterStackView.addArrangedSubview(self.dataTable)
        
        self.summaryTitle.font = FontBook.Body.emphasis
        self.summaryTitle.backgroundColor = ColorPalette.Color.canyonRed
        
        
        self.summaryDetails.font = FontBook.Body.regular
        
        self.dataTitle.font = FontBook.Body.emphasis
        self.dataTitle.backgroundColor = ColorPalette.Color.canyonRed
        self.dataTitle.text = Strings.details
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with canyon: Canyon) {

        self.summaryTitle.text = Strings.summary(for: canyon)
        self.summaryDetails.text = Strings.summaryDetails(for: canyon)
        
        let dataDetails = [
            (title: Strings.numRaps, value: Strings.intValue(int: canyon.numRaps)),
            (title: Strings.longestRap, value: Strings.intValue(int: canyon.maxRapLength)),
            (title: Strings.difficulty, value: Strings.intValue(int: canyon.technicalDifficulty)),
            (title: Strings.water, value: Strings.stringValue(string: canyon.waterDifficulty)),
            (title: Strings.time, value: Strings.stringValue(string: canyon.timeGrade)),
            (title: Strings.restricted, value: Strings.boolValue(bool: canyon.isRestricted)),
            (title: Strings.permits, value: Strings.boolValue(bool: canyon.requiresPermit)),
            (title: Strings.shuttle, value: Strings.boolValue(bool: canyon.requiresShuttle)),
            (title: Strings.vehicle, value: Strings.stringValue(string: canyon.vehicleAccessibility?.rawValue)),
        ]
        let data = DataTableViewData(data: dataDetails)
        self.dataTable.configure(with: data)
        
    }
    
}
