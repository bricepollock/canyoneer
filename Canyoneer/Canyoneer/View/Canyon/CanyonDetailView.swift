//
//  CanyonDetailView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class CanyonDetailView: UIView {
    private let masterStackView = UIStackView()
    private let raps = UILabel()
    private let longestRap = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        
        self.masterStackView.axis = .horizontal
        self.masterStackView.spacing = Grid.medium
        
        self.masterStackView.addArrangedSubview(self.raps)
        self.masterStackView.addArrangedSubview(self.longestRap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with canyon: Canyon) {
        self.raps.text = CanyonResultView.Strings.rapCount(count: canyon.numRaps)
        self.longestRap.text = CanyonResultView.Strings.rapLength(feet: canyon.maxRapLength)
    }
    
}
