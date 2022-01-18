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
    }
    
    private let filterSheet = BottomSheetFilterViewController.shared
    
    private let resultsViewController: ResultsViewController
    private let masterStackView = UIStackView()
    private let searchView = GlobalSearchView()
    private let nearMeButton = RxUIButton()
    
    private let viewModel: SearchViewModel
    internal let bag = DisposeBag()
    
    init(query: String) {
        self.viewModel = SearchViewModel()
        self.resultsViewController = ResultsViewController(type: .search, searchResults: [], viewModel: self.viewModel)
        super.init(nibName: nil, bundle: nil)
        
        self.view.addSubview(self.masterStackView)
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = .zero
        let padding: CGFloat = .medium
        self.masterStackView.constrain.top(to: self.view, atMargin: true, with: padding)
        self.masterStackView.constrain.bottom(to: self.view, atMargin: true, with: -padding)
        self.masterStackView.constrain.leading(to: self.view, with: padding)
        self.masterStackView.constrain.trailing(to: self.view, with: -padding)
        
        self.masterStackView.addArrangedSubview(self.searchView)
        self.masterStackView.addArrangedSubview(self.resultsViewController.view)
        self.addChild(self.resultsViewController)
        self.resultsViewController.didMove(toParent: self)

        self.searchView.searchTextField.delegate = self
        self.searchView.searchTextField.text = query
        self.viewModel.search(query: query)
    }
    
    func bind() {
        self.nearMeButton.configure(text: Strings.nearMe)
        self.nearMeButton.didSelect.subscribeOnNext { [weak self] results in
            let next = NearMeViewController()
            self?.navigationController?.pushViewController(next, animated: true)
        }.disposed(by: self.bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let query = textField.text, query.isEmpty == false else {
            return
        }
        self.viewModel.search(query: query)
    }
}
