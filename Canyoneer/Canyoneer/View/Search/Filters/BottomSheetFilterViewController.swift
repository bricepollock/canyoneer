//
//  SearchBottomSheetViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import UIKit
import RxSwift

class BottomSheetFilterViewController: BottomSheetViewController {
    // we want a global filter configuration across screens: favorites, map, search results
    public static let shared = BottomSheetFilterViewController()

    enum Strings {
        static let save = "Save"
        static let reset = "Reset All"
        static let quality = "Stars"
        static let maxRap = "Max Rappel Length"
        static let feet = "ft"
        static let numRap = "Number Rappels"
        static let technical = CanyonDetailView.Strings.difficulty
        static let one = "1"
        static let two = "2"
        static let three = "3"
        static let four = "4"
        static let five = "5"
        
        static let water = CanyonDetailView.Strings.water
        static let a = "A"
        static let b = "B"
        static let c = "C"

        static let time = CanyonDetailView.Strings.time
        static let shuttle = CanyonDetailView.Strings.shuttle
        static let season = CanyonDetailView.Strings.season
    }
    
    private let resetButton = RxUIButton()
    private let maxRapFilter = SpreadFilter()
    private let numRapFilter = SpreadFilter()
    private let starFitler = MultiSelectFilter()
    private let technicalFilter = MultiSelectFilter()
    private let waterDifficultyFilter = MultiSelectFilter()
    private let timeFilter = MultiSelectFilter()
    private let shuttleFilter = SwitchFilter()
    private let seasonFilter = BestSeasonFilter()

    private let bag = DisposeBag()
    
    override init() {
        super.init()
        
        self.modalPresentationStyle = .overCurrentContext
        
        let saveButton = ContainedButton()
        saveButton.configure(text: Strings.save)
        saveButton.didSelect.subscribeOnNext { () in
            self.animateDismissView()
        }.disposed(by: self.bag)
        
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.addArrangedSubview(UIView())
        headerStackView.addArrangedSubview(self.resetButton)
        self.resetButton.configure(text: Strings.reset)
        
        self.contentStackView.spacing = .medium
        self.contentStackView.addArrangedSubview(headerStackView)
        self.contentStackView.addArrangedSubview(self.starFitler)
        self.contentStackView.addArrangedSubview(self.numRapFilter)
        self.contentStackView.addArrangedSubview(self.maxRapFilter)
        self.contentStackView.addArrangedSubview(self.technicalFilter)
        self.contentStackView.addArrangedSubview(self.waterDifficultyFilter)
        self.contentStackView.addArrangedSubview(self.timeFilter)
        self.contentStackView.addArrangedSubview(self.shuttleFilter)
        self.contentStackView.addArrangedSubview(self.seasonFilter)
        self.contentStackView.addArrangedSubview(saveButton)
        self.contentStackView.addArrangedSubview(UIView())
        
        let numRapData = SpreadFilterData(
            name: Strings.numRap,
            units: nil,
            initialMin: 0,
            initialMax: 50,
            advanceIncrements: 1
        )
        self.numRapFilter.configure(with: numRapData)
        
        let maxRapData = SpreadFilterData(
            name: Strings.maxRap,
            units: Strings.feet,
            initialMin: 0,
            initialMax: 600,
            advanceIncrements: 10
            
        )
        self.maxRapFilter.configure(with: maxRapData)
        
        let starData = MultiSelectFilterData(
            name: Strings.quality,
            selections: [Strings.one, Strings.two, Strings.three, Strings.four, Strings.five],
            initialSelections: [Strings.one, Strings.two, Strings.three, Strings.four, Strings.five]
        )
        self.starFitler.configure(with: starData)
        
        let technicalData = MultiSelectFilterData(
            name: Strings.technical,
            selections: [Strings.one, Strings.two, Strings.three, Strings.four],
            initialSelections: [Strings.one, Strings.two, Strings.three, Strings.four]
        )
        self.technicalFilter.configure(with: technicalData)
        
        let waterSelections = [Strings.a, Strings.b, Strings.c]
        let waterData = MultiSelectFilterData(
            name: Strings.water,
            selections: waterSelections,
            initialSelections: waterSelections
        )
        self.waterDifficultyFilter.configure(with: waterData)
        
        let timeData = MultiSelectFilterData(
            name: Strings.time,
            selections: RomanNumeral.allCases.map { $0.rawValue },
            initialSelections: RomanNumeral.allCases.map { $0.rawValue }
        )
        self.timeFilter.configure(with: timeData)
                
        
        self.shuttleFilter.configure(title: Strings.shuttle)
        
        let seasonData = BestSeasonFilterData(
            name: Strings.season,
            options: Month.allCases.map {
                return SeasonSelection(name: $0.short, isSelected: true)                
            },
            isUserInteractionEnabled: true
        )
        self.seasonFilter.configure(with: seasonData)
        
        self.resetButton.didSelect.subscribeOnNext { () in
            self.numRapFilter.configure(with: numRapData)
            self.maxRapFilter.configure(with: maxRapData)
            self.starFitler.configure(with: starData)
            self.technicalFilter.configure(with: technicalData)
            self.waterDifficultyFilter.configure(with: waterData)
            self.timeFilter.configure(with: timeData)
            self.shuttleFilter.configure(title: Strings.shuttle)
            self.seasonFilter.configure(with: seasonData)
        }.disposed(by: self.bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func filter(canyons: [Canyon]) -> [Canyon] {
        return canyons.filter { canyon in
            // quality
            guard self.starFitler.selections.contains(String(Int(canyon.quality))) else {
                return false
            }
            
            // num raps
            guard let numRaps = canyon.numRaps else { return false }
            guard numRaps >= self.numRapFilter.minValue && numRaps <= self.numRapFilter.maxValue else {
                return false
            }
            
            // max rap
            guard let maxRap = canyon.maxRapLength else { return false }
            guard maxRap >= self.maxRapFilter.minValue && maxRap <= self.maxRapFilter.maxValue else {
                return false
            }
            
            // technical
            guard let technicalRating = canyon.technicalDifficulty else { return false }
            guard self.technicalFilter.selections.contains(String(technicalRating)) else {
                return false
            }
            
            // water
            guard let waterDifficulty = canyon.waterDifficulty else { return false }
            guard waterDifficultyFilter.selections.contains(waterDifficulty) else {
                return false
            }
            
            // Time
            guard let time = canyon.timeGrade else { return false}
            guard timeFilter.selections.contains(time) else {
                return false
            }
            
            // Shuttle (bypass any)
            if shuttleFilter.selections[0] != SwitchFilter.Strings.any {
                let isYes = shuttleFilter.selections[0] == SwitchFilter.Strings.yes
                
                // Don't count canyons without shuttle information
                if let requireShuttle = canyon.requiresShuttle {
                    guard requireShuttle == isYes else {
                        return false
                    }
                // if there is no shuttle information and we've asked for yes then filter out
                } else if isYes {
                    return false
                }
            }

            
            // Season, if any seasons match up
            let bestSeasonsInitials = canyon.bestSeasons.map { $0.short }
            guard Set(bestSeasonsInitials).intersection(self.seasonFilter.selections).count > 0 else {
                return false
            }
            
            // end
            return true
        }
    }
    
    public func filter(results: [SearchResult]) -> [SearchResult] {
        let canyons = results.compactMap { $0.canyonDetails }
        let filtered = self.filter(canyons: canyons)
        return filtered.map {
            return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
        }
    }
}
