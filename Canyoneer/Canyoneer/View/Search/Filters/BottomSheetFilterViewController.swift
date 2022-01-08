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
    enum Strings {
        static let save = "Save"
        
        static let quality = "Quality"
        static let stars = "stars"
        static let maxRap = "Max Rappel Length"
        static let feet = "ft"
        static let numRap = "Number Rappels"
        static let technical = CanyonDetailView.Strings.difficulty
        
        static let water = CanyonDetailView.Strings.water
        static let a = "A"
        static let b = "B"
        static let c = "C"

        static let time = CanyonDetailView.Strings.time
        static let season = "Best Months"
    }
    
    private let starFitler = SpreadFilter()
    private let maxRapFilter = SpreadFilter()
    private let numRapFilter = SpreadFilter()
    private let technicalFilter = SpreadFilter()
    private let waterDifficultyFilter = MultiSelectFilter()
    private let timeFilter = MultiSelectFilter()
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
        
        self.contentStackView.spacing = .medium
        self.contentStackView.addArrangedSubview(self.starFitler)
        self.contentStackView.addArrangedSubview(self.numRapFilter)
        self.contentStackView.addArrangedSubview(self.maxRapFilter)
        self.contentStackView.addArrangedSubview(self.technicalFilter)
        self.contentStackView.addArrangedSubview(self.waterDifficultyFilter)
        self.contentStackView.addArrangedSubview(self.timeFilter)
        self.contentStackView.addArrangedSubview(self.seasonFilter)
        self.contentStackView.addArrangedSubview(saveButton)
        self.contentStackView.addArrangedSubview(UIView())
        
        let starData = SpreadFilterData(name: Strings.quality, units: Strings.stars, initialMin: 1, initialMax: 5)
        self.starFitler.configure(with: starData)
        
        let numRapData = SpreadFilterData(name: Strings.numRap, units: nil, initialMin: 0, initialMax: 50)
        self.numRapFilter.configure(with: numRapData)
        
        let maxRapData = SpreadFilterData(name: Strings.maxRap, units: Strings.feet, initialMin: 1, initialMax: 600)
        self.maxRapFilter.configure(with: maxRapData)
        
        let technicalData = SpreadFilterData(name: Strings.technical, units: nil, initialMin: 1, initialMax: 4)
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
                
        let seasonData = BestSeasonFilterData(
            name: Strings.season,
            options: Month.allCases.map { $0.short }
        )
        self.seasonFilter.configure(with: seasonData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func filter(canyons: [Canyon]) -> [Canyon] {
        return canyons.filter { canyon in
            // num raps
            guard canyon.quality >= Float(self.starFitler.minValue) && canyon.quality <= Float(self.starFitler.maxValue) else {
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
            guard technicalRating >= self.technicalFilter.minValue && technicalRating <= self.technicalFilter.maxValue else {
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
