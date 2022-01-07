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
        static let save = "Save"
    }
    
    // filters
    private let rappelFilter = RappelFilterView()
    
    private let result: SearchResultList
    private let bag = DisposeBag()
    
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(didRequestFilters))
        self.renderResults(results: self.result.result)
    }
    
    private func renderResults(results: [SearchResult]) {
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
                    let next = CanyonViewController(canyon: canyon)
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
        let results = self.result.result.filter { result in
            guard let canyon = result.canyonDetails else {
                return true
            }
            // filter out canyons without this rap information
            guard let maxRap = canyon.maxRapLength else {
                return false
            }
            return maxRap >= self.rappelFilter.minRappels && maxRap <= self.rappelFilter.maxRappels
        }
        self.renderResults(results: results)
    }
    
    @objc func didRequestFilters() {
        
        let bottomSheet = BottomSheetViewController()
        bottomSheet.modalPresentationStyle = .overCurrentContext
        
        let saveButton = ContainedButton()
        saveButton.configure(text: Strings.save)
        saveButton.didSelect.subscribeOnNext { () in
            bottomSheet.animateDismissView()
        }.disposed(by: self.bag)
        
        bottomSheet.contentStackView.spacing = .medium
        bottomSheet.contentStackView.addArrangedSubview(rappelFilter)
        bottomSheet.contentStackView.addArrangedSubview(saveButton)
        bottomSheet.contentStackView.addArrangedSubview(UIView())
        bottomSheet.willDismiss.subscribeOnNext { () in
            self.updateWithFilters()
        }.disposed(by: self.bag)
        self.present(bottomSheet, animated: false)
    }
}
