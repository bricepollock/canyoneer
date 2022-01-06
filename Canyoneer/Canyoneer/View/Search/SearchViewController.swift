//
//  SearchViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class SearchViewController: ScrollableStackViewController {
    private let result: SearchResultList
    
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
        
        self.title = self.result.searchString
        
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(UIView.createLineView())
        self.result.result.forEach { result in
            let view: UIView
            switch result.type {
            case .canyon:
                let specificView = CanyonResultView()
                specificView.configure(with: result)
                view = specificView
            case .region:
                let specificView = RegionResultView()
                specificView.configure(with: result)
                view = specificView
            }
            
            self.masterStackView.addArrangedSubview(view)
            self.masterStackView.addArrangedSubview(UIView.createLineView())
        }
    }
    
    
}
