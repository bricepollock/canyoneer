//
//  ResultsViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit
import SwiftUI
import Combine

enum SearchType: Equatable {
    static func == (lhs: SearchType, rhs: SearchType) -> Bool {
        return lhs.typeValue == rhs.typeValue
    }
    
    case search
    case nearMe
    case favorites
    case map
    
    var typeValue: Int {
        switch self {
        case .search: return 1
        case .nearMe: return 2
        case .favorites: return 3
        case .map: return 4
        }
    }
}

@MainActor
class ResultsViewController: ScrollableStackViewController {
    private let filterSheet = BottomSheetFilterViewController.shared
        
    private let viewModel: ResultsViewModel
    private var filteredResults: [Canyon]?
    
    private var resultCancelables = Set<AnyCancellable>()
    private var bag = Set<AnyCancellable>() // lifetime-bind cancelables
    
    init(type: SearchType, searchResults: [SearchResult], viewModel: ResultsViewModel) {
        self.viewModel = viewModel
        super.init(insets: .init(all: .medium), atMargin: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.bind()

        self.navigationItem.backButtonTitle = ""
        
        // setup loading
        self.view.addSubview(self.viewModel.loadingComponent.inlineLoader)
        self.viewModel.loadingComponent.inlineLoader.constrain.centerX(on: self.view)
        self.viewModel.loadingComponent.inlineLoader.constrain.centerY(on: self.view)
        
        // setup default bar button items        
        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(didRequestMap))
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(didRequestFilters))
        self.navigationItem.rightBarButtonItems = [mapButton, filterButton]
        
        Task(priority: .high) { @MainActor [weak self] in
            await self?.viewModel.refresh()
        }
    }
    
    func configureViews() {
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium        
    }
    
    func bind() {
        self.viewModel.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &bag)
        
        self.viewModel.$currentResults
            .receive(on: DispatchQueue.main) // The CLLocation Near me doesn't respect main actor
            .sink { [weak self] result in
            self?.renderResults(results: result)
        }.store(in: &bag)
        
        self.filterSheet.willDismiss
            .sink { [weak self] _ in
            self?.updateWithFilters()
        }.store(in: &bag)
    }
    
    internal func renderResults(results: [SearchResult]) {
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(UIView.createLineView())
        self.resultCancelables.removeAll()
        results.forEach { result in
            let resultView = CanyonItemView(result: result)
            let hostingViewController = UIHostingController(rootView: resultView)
            resultView.didSelect.sink { [weak self] _ in
                let canyon = result.canyonDetails
                let next = CanyonViewController(canyonId: canyon.id)
                
                if let navigationController = self?.navigationController {
                    navigationController.pushViewController(next, animated: true)
                // hack because UISearchController does not notice the UINavigation controller on SearchViewController
                } else if let navigationController = MainTabBarController.controller(for: .search).navigationController {
                    navigationController.pushViewController(next, animated: true)
                } else {
                    Global.logger.error("Cannot find navigation controller to push from")
                }
            }.store(in: &bag)
            
            self.addChild(hostingViewController)
            self.masterStackView.addArrangedSubview(hostingViewController.view)
            hostingViewController.didMove(toParent: self)
            self.masterStackView.addArrangedSubview(UIView.createLineView())
        }
    }
    
    private func updateWithFilters() {
        self.filterSheet.update()
        // NEED to filter off the initial results otherwise we accumulate our filters until there is none
        let filtered = self.filterSheet.viewModel.filter(results: self.viewModel.initialResults)
        self.viewModel.updateFromFilter(with: filtered)
    }
    
    @objc func didRequestMap() {
        let canyons = self.viewModel.currentResults.compactMap { $0.canyonDetails }
        let next = MapViewController(type: .apple, canyons: canyons)
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func didRequestFilters() {
        self.tabBarController?.present(self.filterSheet, animated: false)
    }
}
