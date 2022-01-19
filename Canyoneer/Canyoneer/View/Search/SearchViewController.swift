//
//  SearchViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class SearchViewController: UIViewController, UITextViewDelegate {
    enum Strings {
        static let title = "Canyoneer"
        static let map = "View Map"
        static let nearMe = "Near Me"
        static let done = "Done"
        static let placeholder = "Search canyons by name"
    }
    
    private let filterSheet = BottomSheetFilterViewController.shared
    
    private let searchController: UISearchController
    private let resultsViewController: ResultsViewController
    
    private let viewModel: SearchViewModel
    internal let bag = DisposeBag()
    
    init() {
        self.viewModel = SearchViewModel()
        self.resultsViewController = ResultsViewController(type: .search, searchResults: [], viewModel: self.viewModel)
        self.searchController = UISearchController(searchResultsController: self.resultsViewController)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.backButtonTitle = ""
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = Strings.placeholder
        self.navigationItem.searchController = self.searchController

        // setup the near me button
        let nearMe = UIBarButtonItem(image: UIImage(systemName: "location.circle"), style: .plain, target: self, action: #selector(self.nearMePressed))
        self.navigationItem.rightBarButtonItems = [nearMe]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func nearMePressed() {
        let next = NearMeViewController()
        self.navigationController?.pushViewController(next, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
      guard let query = searchController.searchBar.text, query.isEmpty == false else {
          self.viewModel.clearResults()
          return
      }
      self.viewModel.search(query: query)
  }
}
