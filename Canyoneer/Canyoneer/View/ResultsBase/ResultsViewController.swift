//
//  ResultsViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit
import RxSwift

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

class ResultsViewController: ScrollableStackViewController {
    private let filterSheet = BottomSheetFilterViewController.shared
        
    private let viewModel: ResultsViewModel
    private var filteredResults: [Canyon]?
    internal let bag = DisposeBag()
    
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
        
        self.viewModel.refresh()
    }
    
    func configureViews() {
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium        
    }
    
    func bind() {
        self.viewModel.title.subscribeOnNext { [weak self] title in
            self?.title = title
        }.disposed(by: self.bag)
        
        self.viewModel.results.subscribeOnNext { [weak self] result in
            self?.renderResults(results: result)
        }.disposed(by: self.bag)
        
        self.filterSheet.willDismiss.subscribeOnNext { [weak self] () in
            self?.updateWithFilters()
        }.disposed(by: self.bag)
    }
    
    internal func renderResults(results: [SearchResult]) {
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(UIView.createLineView())
        results.forEach { result in
            let view: UIView
            switch result.type {
            case .canyon:
                let specificView = CanyonResultView()
                specificView.configure(with: result)
                specificView.didSelect.subscribeOnNext { [weak self] () in
                    guard let canyon = result.canyonDetails else {
                        return
                    }
                    let next = CanyonViewController(canyonId: canyon.id)
                    self?.navigationController?.pushViewController(next, animated: true)
                }.disposed(by: self.bag)
                view = specificView
            case .region:
                let specificView = RegionResultView()
                specificView.configure(with: result)
                specificView.didSelect.subscribeOnNext { [weak self] () in
                    guard let region = result.regionDetails else {
                        return
                    }
                    return // TODO: Refactor out regions
                }.disposed(by: self.bag)
                view = specificView
            }
            
            self.masterStackView.addArrangedSubview(view)
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
        self.present(self.filterSheet, animated: false)
    }
}
