//
//  MapLegendBottomSheetViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import UIKit

class MapLegendBottomSheetViewController: BottomSheetViewController {
    
    enum Strings {
        static let title = "Legend"
        static let driving = "Driving/Shuttle"
        static let exit = "Exit"
        static let approach = "Approach"
        static let descent = "Descent"
        static let other = "Unclassified (See Canyon Map)"
    }
    static let lineWidth: CGFloat = 10
    static let lineLength: CGFloat = 50
    
    private let blueStack = UIStackView()
    private let blueLineTitle = UILabel()
    private let blueLine = UIView.createLineView(height: MapLegendBottomSheetViewController.lineWidth)
    
    private let yellowStack = UIStackView()
    private let yellowLineTitle = UILabel()
    private let yellowLine = UIView.createLineView(height: MapLegendBottomSheetViewController.lineWidth)
    
    private let redStack = UIStackView()
    private let redLineTitle = UILabel()
    private let redLine = UIView.createLineView(height: MapLegendBottomSheetViewController.lineWidth)
    
    private let greenStack = UIStackView()
    private let greenLineTitle = UILabel()
    private let greenLine = UIView.createLineView(height: MapLegendBottomSheetViewController.lineWidth)
    
    private let otherStack = UIStackView()
    private let otherLineTitle = UILabel()
    private let otherLine = UIView.createLineView(height: MapLegendBottomSheetViewController.lineWidth)
    
    override init() {
        super.init()
        
        self.modalPresentationStyle = .overCurrentContext
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        let title = UILabel()
        title.font = FontBook.Subhead.regular
        title.textAlignment = .center
        title.text = Strings.title
        
        self.contentStackView.spacing = .small
        self.contentStackView.addArrangedSubview(title)
        self.contentStackView.addArrangedSubview(self.blueStack)
        self.contentStackView.addArrangedSubview(self.greenStack)
        self.contentStackView.addArrangedSubview(self.redStack)
        self.contentStackView.addArrangedSubview(self.yellowStack)
        self.contentStackView.addArrangedSubview(self.otherStack)
        self.contentStackView.addArrangedSubview(UIView())
        
        self.configure(stack: self.blueStack, title: self.blueLineTitle, line: self.blueLine, text: Strings.driving, color: TopoLineType.driving.color)
        self.configure(stack: self.greenStack, title: self.greenLineTitle, line: self.greenLine, text: Strings.approach, color: TopoLineType.approach.color)
        self.configure(stack: self.redStack, title: self.redLineTitle, line: self.redLine, text: Strings.descent, color: TopoLineType.descent.color)
        self.configure(stack: self.yellowStack, title: self.yellowLineTitle, line: self.yellowLine, text: Strings.exit, color: TopoLineType.exit.color)
        self.configure(stack: self.otherStack, title: self.otherLineTitle, line: self.otherLine, text: Strings.other, color: TopoLineType.unknown.color)
    }
    
    private func configure(stack: UIStackView, title: UILabel, line: UIView, text: String, color: UIColor) {
        stack.axis = .horizontal
        stack.spacing = .medium
        stack.addArrangedSubview(title)
        
        let centeringStack = UIStackView()
        centeringStack.axis = .vertical
        centeringStack.addArrangedSubview(UIView())
        centeringStack.addArrangedSubview(line)
        centeringStack.addArrangedSubview(UIView())
        stack.addArrangedSubview(centeringStack)
        
        title.text = text
        line.backgroundColor = color
        line.constrain.width(Self.lineLength)
    }
}
