//
//  BestSeasonFilter.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import UIKit

class SeasonView: UIView {
    
    public var isSelected: Bool
    
    private let month = UILabel()
    private let size: CGFloat = 20
    private let selectionColor = ColorPalette.Color.action
    
    var text: String? {
        return month.text
    }
    
    init() {
        self.isSelected = false
        super.init(frame: .zero)
        self.layer.cornerRadius = self.size / 2
        self.addSubview(self.month)
        self.month.constrain.fillSuperview(offsets: .init(all: .xSmall))
        self.month.font = FontBook.Body.regular
        self.chooseSelection(self.isSelected)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func chooseSelection(_ isSelected: Bool) {
        self.isSelected = isSelected
        self.backgroundColor = isSelected ? selectionColor : ColorPalette.GrayScale.white
        self.month.textColor = isSelected ? ColorPalette.GrayScale.white : ColorPalette.GrayScale.black
    }
    
    public func configure(name: String) {
        self.month.text = name
    }
    
    @objc func didTap() {
        self.chooseSelection(!isSelected)
    }
}

struct BestSeasonFilterData {
    let name: String
    let options: [SeasonSelection]
}

struct SeasonSelection {
    let name: String
    let isSelected: Bool
}

class BestSeasonFilter: UIView {

    private let masterStackView = UIStackView()
    private let firstRow = UIStackView()
    private let secondRow = UIStackView()
    private let titleLabel = UILabel()
    
    public var selections: [String] {
        let views = firstRow.arrangedSubviews + secondRow.arrangedSubviews
        return views.compactMap {
            return $0 as? SeasonView
        }.filter {
            return $0.isSelected
        }.compactMap {
            return $0.text
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = .small
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = FontBook.Body.emphasis
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: BestSeasonFilterData) {
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(self.titleLabel)
        self.titleLabel.text = data.name

        let mid = data.options.count / 2
        let firstRowData = data.options.prefix(mid)
        let secondRowData = data.options.dropFirst(mid)
        
        firstRow.distribution = .equalSpacing
        firstRow.alignment = .center
        firstRowData.forEach {
            let monthView = SeasonView()
            monthView.configure(name: $0.name)
            monthView.chooseSelection($0.isSelected)
            firstRow.addArrangedSubview(monthView)
        }
        self.masterStackView.addArrangedSubview(firstRow)
        
        secondRow.distribution = .equalSpacing
        secondRowData.forEach {
            let monthView = SeasonView()
            monthView.configure(name: $0.name)
            monthView.chooseSelection($0.isSelected)
            secondRow.addArrangedSubview(monthView)
        }
        
        self.masterStackView.addArrangedSubview(secondRow)
    }
}
