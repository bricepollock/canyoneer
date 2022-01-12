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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // FIXME: Respond reactive to each of these objects
    public func update() {
        self.viewModel.update(maxRap: (max: self.maxRapFilter.maxValue, self.maxRapFilter.minValue))
        self.viewModel.update(numRaps: (max: self.numRapFilter.maxValue, self.numRapFilter.minValue))

        self.viewModel.update(stars: self.starFitler.selections)
        self.viewModel.update(technicality: self.technicalFilter.selections)
        self.viewModel.update(water: self.waterDifficultyFilter.selections)
        self.viewModel.update(time: self.timeFilter.selections)
        self.viewModel.update(shuttle: self.shuttleFilter.selections.first)
        self.viewModel.update(seasons: self.seasonFilter.selections)
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
            initialMin: state.numRaps.min,
            initialMax: state.numRaps.max,
            advanceIncrements: 1
        )
        self.numRapFilter.configure(with: numRapData)
        
        let maxRapData = SpreadFilterData(
            name: Strings.maxRap,
            units: Strings.feet,
            initialMin: state.maxRap.min,
            initialMax: state.maxRap.max,
            advanceIncrements: 10
            
        )
        self.maxRapFilter.configure(with: maxRapData)
        
        let starData = MultiSelectFilterData(
            name: Strings.quality,
            selections: state.stars.map { String($0)},
            initialSelections: state.stars.map { String($0)}
        )
        self.starFitler.configure(with: starData)
        
        let technicalData = MultiSelectFilterData(
            name: Strings.technical,
            selections: state.technicality.map { String($0)},
            initialSelections: state.technicality.map { String($0)}
        )
        self.technicalFilter.configure(with: technicalData)
        
        let waterData = MultiSelectFilterData(
            name: Strings.water,
            selections: state.water,
            initialSelections: state.water
        )
        self.waterDifficultyFilter.configure(with: waterData)
        
        let timeData = MultiSelectFilterData(
            name: Strings.time,
            selections: state.time.map { $0.rawValue },
            initialSelections: state.time.map { $0.rawValue }
        )
        self.timeFilter.configure(with: timeData)
        
        self.shuttleFilter.configure(title: Strings.shuttle)
        
        let seasonData = BestSeasonFilterData(
            name: Strings.season,
            options: state.seasons.map {
                return SeasonSelection(name: $0.short, isSelected: true)                
            },
            isUserInteractionEnabled: true
        )
        self.seasonFilter.configure(with: seasonData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
