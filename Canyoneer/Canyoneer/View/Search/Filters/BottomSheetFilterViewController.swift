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

    // FIXME: Still figuring out how to communicate filters
    public let viewModel = FilterViewModel()
    private let bag = DisposeBag()
    
    override init() {
        super.init()
        
        self.modalPresentationStyle = .overCurrentContext
        self.configureViews()
        self.bind()
        
        // only reset on view controller creation
        // this means throughout a session the filters will remain consistent globally
        // but across sessions they will be reset (on every cold launch)
        self.viewModel.reset()
    }
    
    // FIXME: Respond reactive to each of these objects
    public func update() {
        // if we don't capture the state and send individually then when the whole state update comes in (on first update call)
        // it will clear out state for all other items
        
        let maxRap = (max: self.maxRapFilter.maxValue, self.maxRapFilter.minValue)
        let numRaps = (max: self.numRapFilter.maxValue, self.numRapFilter.minValue)
        let stars = self.starFitler.selections
        let technicality = self.technicalFilter.selections
        let water = self.waterDifficultyFilter.selections
        let time = self.timeFilter.selections
        let shuttle = self.shuttleFilter.selections.first
        let seasons = self.seasonFilter.selections
        
        self.viewModel.update(maxRap: maxRap)
        self.viewModel.update(numRaps: numRaps)
        self.viewModel.update(stars: stars)
        self.viewModel.update(technicality: technicality)
        self.viewModel.update(water: water)
        self.viewModel.update(time: time)
        self.viewModel.update(shuttle: shuttle)
        self.viewModel.update(seasons: seasons)
    }
    
    private func configureViews() {
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
    }
    
    private func bind() {
        self.viewModel.state.subscribeOnNext { [weak self] state in
            self?.configure(with: state)
        }.disposed(by: self.bag)
        self.resetButton.didSelect.subscribeOnNext { [weak self] () in
            self?.viewModel.reset()
        }.disposed(by: self.bag)
    }
    
    private func configure(with state: FilterState) {
        let numRapData = SpreadFilterData(
            name: Strings.numRap,
            units: nil,
            initialMin: self.viewModel.initialState.numRaps.min,
            currentMin: state.numRaps.min,
            initialMax: self.viewModel.initialState.numRaps.max,
            currentMax: state.numRaps.max,
            advanceIncrements: 1
        )
        self.numRapFilter.configure(with: numRapData)
        
        let maxRapData = SpreadFilterData(
            name: Strings.maxRap,
            units: Strings.feet,
            initialMin: self.viewModel.initialState.maxRap.min,
            currentMin: state.maxRap.min,
            initialMax: self.viewModel.initialState.maxRap.max,
            currentMax: state.maxRap.max,
            advanceIncrements: 10
            
        )
        self.maxRapFilter.configure(with: maxRapData)
        
        let starData = MultiSelectFilterData(
            name: Strings.quality,
            selections: self.viewModel.initialState.stars.map { String($0)},
            initialSelections: state.stars.map { String($0)}
        )
        self.starFitler.configure(with: starData)
        
        let technicalData = MultiSelectFilterData(
            name: Strings.technical,
            selections: self.viewModel.initialState.technicality.map { String($0)},
            initialSelections: state.technicality.map { String($0)}
        )
        self.technicalFilter.configure(with: technicalData)
        
        let waterData = MultiSelectFilterData(
            name: Strings.water,
            selections: self.viewModel.initialState.water,
            initialSelections: state.water
        )
        self.waterDifficultyFilter.configure(with: waterData)
        
        let timeData = MultiSelectFilterData(
            name: Strings.time,
            selections: self.viewModel.initialState.time.map { $0.rawValue },
            initialSelections: state.time.map { $0.rawValue }
        )
        self.timeFilter.configure(with: timeData)
        
        self.shuttleFilter.configure(title: Strings.shuttle, isYes: state.shuttleRequired)
        
        let seasonData = BestSeasonFilterData(
            name: Strings.season,
            options: self.viewModel.initialState.seasons.map {
                let isSelected = state.seasons.contains($0)
                return SeasonSelection(name: $0.short, isSelected: isSelected)
            },
            isUserInteractionEnabled: true
        )
        self.seasonFilter.configure(with: seasonData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
