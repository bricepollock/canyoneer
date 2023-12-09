//  Created by Brice Pollock for Canyoneer on 12/3/23

import SwiftUI

struct BestSeasonsView: View {
    @ObservedObject var viewModel: BestSeasonsViewModel
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: Grid.small) {
            HStack(spacing: Grid.small) {
                Spacer()
                Text(Strings.title)
                    .font(FontBook.Body.emphasis)
                    .multilineTextAlignment(.center)
                if viewModel.isUserInteractionEnabled {
                    Button(action: {
                        viewModel.toggleAllSelection()
                    }) {
                        Text(viewModel.isAnySelected ? Strings.none : Strings.all)
                            .font(FontBook.Body.emphasis)
                            .foregroundColor(ColorPalette.Color.action)
                    }
                }
                Spacer()
            }
            VStack(alignment: .center) {
                HStack(spacing: 20) {
                    ForEach(viewModel.topRow) {
                        monthView(for: $0)
                    }
                }
                HStack(spacing: 20) {
                    ForEach(viewModel.bottomRow) {
                        monthView(for: $0)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func monthView(for month: Month) -> some View {
        Button(action: {
            guard viewModel.isUserInteractionEnabled else { return }
            viewModel.toggle(for: month)
        }, label: {
            Text(month.short)
                .font(FontBook.Body.regular)
                .padding(.vertical, Grid.xSmall)
                .padding(.horizontal, Grid.small)
                .foregroundColor(viewModel.isSelected(month) ? ColorPalette.GrayScale.white : ColorPalette.GrayScale.black)
                .background(viewModel.isSelected(month) ? ColorPalette.Color.action : ColorPalette.GrayScale.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        })
    }
    
    private enum Strings {
        static let title = "Best Months"
        static let all = "All"
        static let none = "None"
    }
}

