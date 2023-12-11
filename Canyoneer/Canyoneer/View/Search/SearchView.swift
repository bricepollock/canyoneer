//
//  SearchViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    @State var showCanyonWithID: String?
    @State var isSearchPresent: Bool = false
    
    @ViewBuilder
    var body: some View {
        NavigationStack {
            VStack {
                // Did a bunch of work around and could not get this work on 17-
                if #available(iOS 17.0, *) {
                    ResultListView(viewModel: viewModel)
                        .searchable(text: $viewModel.query, isPresented: $isSearchPresent, prompt: Strings.placeholder)
                        .overlay {
                            if isSearchPresent == false {
                                    VStack {
                                        NavigationLink {
                                            NearMeView(viewModel: viewModel.nearMeViewModel)
                                        } label: {
                                            // It was impossible to get we wanted with SwiftUI searchable over the search area like before and using UIKit broke everything in other ways so this is our gross workaround. A centered text button that wont even render without a manual frame...
                                            HStack {
                                                Image(uiImage: UIImage(systemName: "location.circle")!.withRenderingMode(.alwaysTemplate))
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(ColorPalette.Color.action)
                                                Text(Strings.searchNearMe)
                                                    .font(FontBook.Subhead.emphasis)
                                                    .foregroundColor(ColorPalette.Color.action)
                                            }
                                            .frame(width: 300, height: 24)
                                        }
                                        Spacer()
                                    }
                            } else {
                                EmptyView()
                            }
                        }
                } else {
                    ResultListView(viewModel: viewModel)
                        .searchable(text: $viewModel.query, prompt: Strings.placeholder)
                }
            }
        }
    }
    
    private enum Strings {
        static let searchNearMe = "Search Near Me"
        static let placeholder = "Search canyons by name"
    }
}
