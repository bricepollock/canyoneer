//
//  NearMeViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit

class NearMeViewController: ResultsViewController {
    private let viewModel = NearMeViewModel()
    
    init() {
        super.init(type: .nearMe, searchResults: [], viewModel: self.viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() // this calls refresh on the view model
    }
}
