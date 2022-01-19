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
    }
    
    private let filterSheet = BottomSheetFilterViewController.shared
    
    private let resultsViewController: ResultsViewController
    private let masterStackView = UIStackView()
    private let searchView = GlobalSearchView()
    
    private let viewModel: SearchViewModel
    internal let bag = DisposeBag()
    
    init() {
        self.viewModel = SearchViewModel()
        self.resultsViewController = ResultsViewController(type: .search, searchResults: [], viewModel: self.viewModel)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.backButtonTitle = ""
        
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

        // setup the near me button
        let nearMe = UIBarButtonItem(image: UIImage(systemName: "location.circle"), style: .plain, target: self, action: #selector(self.nearMePressed))
        self.navigationItem.rightBarButtonItems = [nearMe]
        
        self.searchView.searchTextField.delegate = self
        
        // Add done to top of keyboard to get back to tab bar
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: Strings.done, style: .done, target: self, action: #selector(donePressed))
        doneToolbar.items = [flexSpace, done]
        self.searchView.searchTextField.inputAccessoryView = doneToolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.searchView.searchTextField.text?.isEmpty == true {
            self.searchView.searchTextField.becomeFirstResponder()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func donePressed() {
        self.searchView.searchTextField.resignFirstResponder()
    }
    
    @objc func nearMePressed() {
        let next = NearMeViewController()
        self.navigationController?.pushViewController(next, animated: true)
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let query = textField.text, query.isEmpty == false else {
            self.viewModel.clearResults()
            return
        }
        self.viewModel.search(query: query)
    }
}
