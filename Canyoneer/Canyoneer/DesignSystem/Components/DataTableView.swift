//
//  DataTable.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import SwiftUI

struct DataTableView: View {
    let viewModel: DataTableViewModel
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.rows) { row in
                HStack {
                    HStack {
                        Text(row.title)
                            .font(FontBook.Body.emphasis)
                        Spacer()
                    }
                    .frame(width: 160)
                    
                    Text(row.value)
                        .font(FontBook.Body.regular)
                    
                    Spacer()
                }
                .padding(.horizontal, CanyonDetailView.horizontalPadding)
                .padding(.vertical, Grid.small)
                .background(row.background)
            }
        }
    }
}
