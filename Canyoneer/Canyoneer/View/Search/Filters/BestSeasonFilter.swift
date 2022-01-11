//
//  BestSeasonFilter.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import UIKit
import RxSwift

struct BestSeasonFilterData {
    let name: String
    let options: [SeasonSelection]
    let isUserInteractionEnabled: Bool
}

struct SeasonSelection {
    let name: String
    let isSelected: Bool
}

class BestSeasonFilter: UIView {

    enum Strings {
        static let all = "All       "
        static let none = "None      "
    }
    
    private let masterStackView = UIStackView()
    private let titleStackView = UIStackView()
    private let massSelectionButton = RxUIButton()
    private let firstRow = UIStackView()
    private let secondRow = UIStackView()
    private let titleLabel = UILabel()
    
    private let bag = DisposeBag()
    
    public var selections: [String] {
        return seasonButtons.filter {
            return $0.isSelected
        }.compactMap {
            return $0.text
        }
    }
    
    public var seasonButtons: [SeasonView] {
        let views = firstRow.arrangedSubviews + secondRow.arrangedSubviews
        return views.compactMap {
            return $0 as? SeasonView
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
        
        self.addSubview(self.massSelectionButton)
        self.massSelectionButton.didSelect.subscribeOnNext { () in
            let isAnySelected = self.selections.count > 0
            let shouldHighlightAll = !isAnySelected
            self.seasonButtons.forEach {
                $0.chooseSelection(shouldHighlightAll)
            }
        }.disposed(by: self.bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: BestSeasonFilterData) {
        self.isUserInteractionEnabled = data.isUserInteractionEnabled
        self.massSelectionButton.isHidden = !data.isUserInteractionEnabled
        
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(self.titleStackView)
        
        self.titleStackView.removeAll()
        self.titleStackView.axis = .horizontal
        self.titleStackView.alignment = .center
        self.titleStackView.distribution = .equalCentering
        self.titleStackView.addArrangedSubview(UIView())
        self.titleStackView.addArrangedSubview(self.titleLabel)
        self.titleStackView.addArrangedSubview(UIView())
        
        self.massSelectionButton.constrain.horizontalSpacing(to: self.titleLabel, with: Grid.small)
        self.massSelectionButton.constrain.height(to: self.titleLabel)
        
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.titleLabel.textAlignment = .center
        self.titleLabel.text = data.name
        self.massSelectionButton.configure(text: Strings.none)
        self.massSelectionButton.contentHorizontalAlignment = .left
        self.massSelectionButton.didSelect.subscribeOnNext { () in
            let isAnySelected = self.selections.count > 0
            self.massSelectionButton.configure(text: isAnySelected ? Strings.none : Strings.all)
        }.disposed(by: self.bag)
        
        // to collect all button selections so if any is selected we can update our massSelectionButton
        var buttonSelections = [Observable<Void>]()

        // show two rows of months because we cannot cramp them all visually into one line
        let mid = data.options.count / 2
        let firstRowData = data.options.prefix(mid)
        let secondRowData = data.options.dropFirst(mid)
        
        self.firstRow.removeAll()
        firstRow.distribution = .equalSpacing
        firstRow.alignment = .center
        firstRowData.forEach {
            let monthView = SeasonView()
            monthView.configure(name: $0.name)
            monthView.chooseSelection($0.isSelected)
            buttonSelections.append(monthView.didSelect)
            firstRow.addArrangedSubview(monthView)
        }
        self.masterStackView.addArrangedSubview(firstRow)
        
        self.secondRow.removeAll()
        secondRow.distribution = .equalSpacing
        secondRowData.forEach {
            let monthView = SeasonView()
            monthView.configure(name: $0.name)
            monthView.chooseSelection($0.isSelected)
            buttonSelections.append(monthView.didSelect)
            secondRow.addArrangedSubview(monthView)
        }
        
        self.masterStackView.addArrangedSubview(secondRow)
        
        // if any button selected then update massSelectionButton
        Observable.merge(buttonSelections).subscribeOnNext { () in
            let isAnySelected = self.selections.count > 0
            self.massSelectionButton.configure(text: isAnySelected ? Strings.none : Strings.all)
        }.disposed(by: self.bag)
    }
}
