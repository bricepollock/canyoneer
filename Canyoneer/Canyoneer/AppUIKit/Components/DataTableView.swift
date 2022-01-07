//
//  DataTable.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import UIKit

struct DataTableViewData {
    let data: [(title: String, value: String)]
}

class DataTableView: UIView {
    private let masterStackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: DataTableViewData) {
        self.masterStackView.removeAll()
        data.data.enumerated().forEach { tuple in
            let (index, dataTuple) = tuple
            let backgroundColor = index % 2 == 0 ? ColorPalette.GrayScale.white : ColorPalette.GrayScale.light
            let title = UILabel()
            title.font = FontBook.Body.emphasis
            title.backgroundColor = backgroundColor
            title.text = dataTuple.title
            
            let value = UILabel()
            value.font = FontBook.Body.regular
            value.backgroundColor = backgroundColor
            value.text = dataTuple.value
            
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = .medium
            row.addArrangedSubview(title)
            row.addArrangedSubview(value)
            
            self.masterStackView.addArrangedSubview(row)
        }
    }
    
}
