//
//  CanyonItemView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/31/22.
//

import SwiftUI

struct CanyonItemView: View {
    @State var result: QueryResult
    
    var body: some View {
        HStack(alignment: .center, spacing: .medium) {
            Text(result.name)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                // make the text fill all remaining space in stack
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .center , spacing: .small) {
                StarQualityView(viewModel: StarQualityViewModel(quality: result.canyonDetails.quality))
                Text(result.canyonDetails.technicalSummary)
            }
        }
        .padding(.horizontal, .medium)
        .background(ColorPalette.GrayScale.white)
    }
}

struct CanyonItemView_Previews: PreviewProvider {
    static var previews: some View {
        let result = QueryResult(name: "Moonflower Canyon with a long name", canyonDetails: Canyon.dummy())
        CanyonItemView(result: result)
    }
}
