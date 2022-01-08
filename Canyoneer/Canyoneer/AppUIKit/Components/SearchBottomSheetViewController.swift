//
//  SearchBottomSheetViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import UIKit
import RxSwift

class SearchBottomSheetViewController: BottomSheetViewController {
    enum Strings {
        static let save = "Save"
    }
    
    public let maxRapFilter = MaxRappelFilter()
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
        self.contentStackView.addArrangedSubview(self.maxRapFilter)
        self.contentStackView.addArrangedSubview(saveButton)
        self.contentStackView.addArrangedSubview(UIView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func filter(canyons: [Canyon]) -> [Canyon] {
        return canyons.filter { canyon in
            // filter out canyons without this rap information
            guard let maxRap = canyon.maxRapLength else {
                return false
            }
            return maxRap >= self.maxRapFilter.minRappels && maxRap <= self.maxRapFilter.maxRappels
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
