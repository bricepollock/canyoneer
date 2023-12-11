//  Created by Brice Pollock for Canyoneer on 12/2/23

import SwiftUI

enum FilterType: Identifiable {
    var id: String {
        switch self {
        case .singleSelect(let title, _): return title
        case .multiSelect(let title, _): return title
        case .spread(let viewModel): return viewModel.name
        case .season: return "Season"
        }
    }
    case singleSelect(title: String, viewModel: SingleSelectViewModel)
    case multiSelect(title: String, viewModel: MultiSelectViewModel)
    case spread(viewModel: SpreadFilterViewModel)
    case season(viewModel: BestSeasonsViewModel)
}

@MainActor
class CanyonFilterSheetViewModel: ObservableObject {
    @Published private(set) var filters: [FilterType]?
    
    private let filterViewModel: CanyonFilterViewModel
    
    init(filterViewModel: CanyonFilterViewModel) {
        self.filterViewModel = filterViewModel
    }
    
    // Need to do this in appear because the ViewModel is re-created on each modification of state when modifying filter which causes a view-refresh and which in turn regenerates all the view-objeccts in the destination closures. This strategy doesn't make sense as a UI-framework, but maybe I don't understand SwiftUI navigation well yet. This ensures we aren't generating new filter components and reseting state every time we modify state.
    public func refresh() {
        let filterWhenPresented = filterViewModel.currentState
        filters = [
            starFilter(for: filterWhenPresented),
            numRaps(for: filterWhenPresented),
            maxRap(for: filterWhenPresented),
            technicality(for: filterWhenPresented),
            water(for: filterWhenPresented),
            time(for: filterWhenPresented),
            shuttle(for: filterWhenPresented),
            season(for: filterWhenPresented)
        ]
    }
    
    public func reset() {
        self.filterViewModel.reset()
        self.refresh()
    }
    
    // MARK: Filters
    
    private func starFilter(for currentState: FilterState) -> FilterType {
        let selectedStars = Set(currentState.stars.map {
            String($0)
        })
        let choices = (1...5).map {
            String($0)
        }
        let selectionViewModel =  MultiSelectViewModel(selections: selectedStars, choices: choices)
        selectionViewModel.$selections
            .dropFirst() // Ignore initialization
            .map { list in
                Set(list.compactMap { choice in
                    Int(choice)
                })
            }
            .assign(to: &filterViewModel.$stars)
        return .multiSelect(title: Strings.quality, viewModel: selectionViewModel)
    }
    
    private func numRaps(for currentState: FilterState) -> FilterType {
        let numRaps = SpreadFilterViewModel(
            name: Strings.numRap,
            spreadData: ComparisonPickerData(
                current: currentState.numRaps,
                limits: FilterState.default.numRaps,
                increments: FilterState.numRapsIncrement
            ),
            units: nil
        )
        numRaps.comparisonPicker.$state
            .dropFirst() // Ignore initialization
            .assign(to: &filterViewModel.$numRaps)
        return .spread(viewModel: numRaps)
    }
    
    private func maxRap(for currentState: FilterState) -> FilterType {
        let maxRap = SpreadFilterViewModel(
            name: Strings.maxRap,
            spreadData: ComparisonPickerData(
                current: currentState.maxRap,
                limits: FilterState.default.maxRap,
                increments: FilterState.maxRapIncrement
            ),
            units: Strings.feet
        )
        maxRap.comparisonPicker.$state
            .dropFirst() // Ignore initialization
            .assign(to: &filterViewModel.$maxRap)
        return .spread(viewModel: maxRap)
    }
    
    private func technicality(for currentState: FilterState) -> FilterType {
        let technicality = MultiSelectViewModel(
            selections: Set(currentState.technicality.map {
                $0.text
            }),
            choices: FilterState.default.technicality
                .sorted(by: { lhs, rhs in
                    lhs.rawValue < rhs.rawValue
                })
                .map {
                    $0.text
                }
        )
        technicality.$selections
            .dropFirst() // Ignore initialization
            .map { list in
                Set(list.compactMap { choice in
                    TechnicalGrade(text: choice)
                })
            }
            .assign(to: &filterViewModel.$technicality)
        return .multiSelect(title: Strings.technical, viewModel: technicality)
    }
    
    private func water(for currentState: FilterState) -> FilterType {
        let water = MultiSelectViewModel(
            selections: Set(currentState.water.map {
                $0.text
            }),
            choices: FilterState.default.water
                .sorted(by: { lhs, rhs in
                    lhs.rawValue < rhs.rawValue
                })
                .map {
                    $0.text
                }
        )
        water.$selections
            .dropFirst() // Ignore initialization
            .map { list in
                Set(list.compactMap { choice in
                    WaterGrade(rawValue: choice)
                })
            }
            .assign(to: &filterViewModel.$water)
        return .multiSelect(title: Strings.water, viewModel: water)
    }
    
    private func time(for currentState: FilterState) -> FilterType {
        let time = MultiSelectViewModel(
            selections: Set(currentState.time.map {
                $0.text
            }),
            choices: FilterState.default.time
                .sorted(by: { lhs, rhs in
                    lhs.number < rhs.number
                })
                .map {
                    $0.text
                }
        )
        time.$selections
            .dropFirst() // Ignore initialization
            .map { list in
                Set(list.compactMap { choice in
                    TimeGrade(rawValue: choice)
                })
            }
            .assign(to: &filterViewModel.$time)
        return .multiSelect(title: Strings.time, viewModel: time)
    }
    
    private func shuttle(for currentState: FilterState) -> FilterType {
        let shuttle = SingleSelectViewModel(selection: currentState.shuttleRequired )
        shuttle.$selection
            .dropFirst() // Ignore initialization
            .map { choice in
                BoolChoice(text: choice)?.value
            }
            .assign(to: &filterViewModel.$shuttleRequired)
                
        return .singleSelect(title: Strings.shuttle, viewModel: shuttle)
    }
    
    private func season(for currentState: FilterState) -> FilterType {
        let season = BestSeasonsViewModel(selections: currentState.seasons, isUserInteractionEnabled: true)
        season.$selections
            .dropFirst() // Ignore initialization
            .assign(to: &filterViewModel.$seasons)
        return .season(viewModel: season)
    }
    
    // Titles
    private enum Strings {
        static let quality = "Stars"
        static let maxRap = "Max Rappel Length"
        static let feet = "ft"
        static let numRap = "Number Rappels"
        static let technical = CommonStrings.technicalGradeTitle
        static let water = CommonStrings.waterGradeTitle
        static let time = CommonStrings.timeGradeTitle
        static let shuttle = CommonStrings.canyonShuttleRequirementTitle
    }
}
