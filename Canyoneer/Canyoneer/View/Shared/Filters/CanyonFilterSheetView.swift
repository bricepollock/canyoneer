//
//  SearchBottomSheetViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import SwiftUI

struct CanyonFilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CanyonFilterSheetViewModel
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: Grid.medium) {
            HStack {
                Spacer()
                SimpleButton(Strings.reset) {
                    viewModel.reset()
                }
            }
            if let filters = viewModel.filters {
                ForEach(filters) { filter in
                    filterView(for: filter)
                }
            } else {
                LargeProgressView()
            }
            ContainedButton(title: Strings.dismiss) {
                dismiss()
            }
            Spacer()
        }
        .padding(Grid.medium)
        .presentationDetents([.height(550)])
        .onAppear {
            viewModel.refresh()
        }
    }

    @ViewBuilder
    func filterView(for filter: FilterType) -> some View {
        switch filter {
        case let .singleSelect(title, viewModel):
            HStack {
                Text(title)
                    .font(FontBook.Body.regular)
                Spacer()
                SingleSelectView(viewModel: viewModel)
            }
        case let .multiSelect(title, viewModel):
            HStack {
                Text(title)
                    .font(FontBook.Body.regular)
                Spacer()
                MultiSelectView(viewModel: viewModel)
            }
        case let .spread(viewModel):
            SpreadFilter(viewModel: viewModel)
        case let .season(viewModel):
            BestSeasonsView(viewModel: viewModel)
        }
    }
    
    private enum Strings {
        static let dismiss = "Dismiss"
        static let reset = "Reset All"
    }
}
