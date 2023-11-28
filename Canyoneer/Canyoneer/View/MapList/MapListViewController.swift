//
//  MapListViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit

class MapListViewController: ResultsViewController {
    
    private let viewModel: MapListViewModel
    init(canyons: [Canyon]) {
        self.viewModel = MapListViewModel(canyons: canyons)
        super.init(type: .map, searchResults: self.viewModel.currentResults, viewModel: self.viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = []
        
    }
}
