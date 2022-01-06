//
//  CanyonViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class CanyonViewController: ScrollableStackViewController {
    enum Strings {
        static func name(with name: String) -> String {
            return "Canyon: \(name)"
        }
    }

    private let name = UILabel()
    private let detailView = CanyonDetailView()
    
    private let canyon: Canyon
    
    init(canyon: Canyon) {
        self.canyon = canyon
        super.init(insets: .init(all: .medium), atMargin: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium
        self.masterStackView.addArrangedSubview(self.name)
        self.masterStackView.addArrangedSubview(self.detailView)
        
        self.title = Strings.name(with: canyon.name)
        self.navigationItem.backButtonTitle = ""
        self.detailView.configure(with: canyon)
    }
}
