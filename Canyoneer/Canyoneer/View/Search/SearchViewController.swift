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
        
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(UIView.createLineView())
        self.result.result.forEach { result in
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
    
    
}
