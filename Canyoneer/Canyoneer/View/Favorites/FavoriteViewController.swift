//
//  FavoriteViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/11/22.
//

import Foundation
import UIKit
import RxSwift

class FavoriteViewController: SearchViewController {
    private let viewModel = FavoriteViewModel()
    
    init() {
        let resultList = SearchResultList(searchString: "Favorites", result: [])
        super.init(result: resultList)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.canyons.subscribeOnNext { canyons in
            let results = canyons.map {
                return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
            }
            self.renderResults(results: results)
        }.disposed(by: self.bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.refresh()
    }
}
