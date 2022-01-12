//
//  SearchViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class SearchViewController: ScrollableStackViewController {
    enum Strings {
        static func title(search: String) -> String {
            return "Search: \(search)"
        }
    }
    
    private let filterSheet = BottomSheetFilterViewController.shared
    
    private let result: SearchResultList
    private var filteredResults: [Canyon]?
    internal let bag = DisposeBag()
    
    init(result: SearchResultList) {
        self.result = result
        super.init(insets: .init(all: .medium), atMargin: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium
        
        self.title = Strings.title(search: self.result.searchString)
        self.navigationItem.backButtonTitle = ""
        
        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(didRequetMap))
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(didRequestFilters))
        self.navigationItem.rightBarButtonItems = [mapButton, filterButton]
        self.renderResults(results: self.result.result)
        
        self.filterSheet.willDismiss.subscribeOnNext { () in
            self.updateWithFilters()
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
                    let next = RegionViewController(region: region)
                    self?.navigationController?.pushViewController(next, animated: true)
                }.disposed(by: self.bag)
                view = specificView
            }
            
            self.masterStackView.addArrangedSubview(view)
            self.masterStackView.addArrangedSubview(UIView.createLineView())
        }
    }
    
    private func updateWithFilters() {
        let filtered = self.filterSheet.filter(results: self.result.result)
        self.filteredResults = filtered.compactMap { $0.canyonDetails }
        self.renderResults(results: filtered)
    }
    
    @objc func didRequetMap() {
        let canyons = self.filteredResults ?? self.result.result.compactMap { $0.canyonDetails }
        let next = MapViewController(canyons: canyons)
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func didRequestFilters() {
        self.present(self.filterSheet, animated: false)
    }
}
