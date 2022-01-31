//
//  CanyonItemView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/31/22.
//

import SwiftUI
import RxSwift
import Combine

struct CanyonItemView: View {
    private static func stars(quality: Float) -> [UIImage] {
        var images = [UIImage?]()
        var remainingQuality = quality
        while remainingQuality > 0 {
            if remainingQuality >= 1 {
                images.append(UIImage(named: "emj_star_full"))
            } else if remainingQuality >= 0.5 {
                images.append(UIImage(named: "emj_star_half"))
            } // else no star because less than 0.5
            remainingQuality -= 1
        }
        return images.compactMap {
            return $0
        }
    }
    private static let imageWidth: CGFloat = 20
    
    public var didSelect: AnyPublisher<Void, Never> {
        return self.didSelectSubject.eraseToAnyPublisher()
    }
    private let didSelectSubject = PassthroughSubject<Void, Never>()
    
    @State var result: SearchResult
    var qualityImages: [UIImage] {
        return Self.stars(quality: result.canyonDetails.quality)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: .medium) {
            Text(result.name)
                .lineLimit(0)
                .multilineTextAlignment(.leading)
                // make the text fill all remaining space in stack
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .center , spacing: .medium) {
                HStack {
                    ForEach(0 ..< self.qualityImages.count, id: \.self) { position in
                        Image(uiImage: qualityImages[position])
                            .resizable()
                            .frame(width: Self.imageWidth, height: Self.imageWidth, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                    }
                }.lineSpacing(1)
                Text(CanyonDetailView.Strings.summaryDetails(for: result.canyonDetails))
            }
        }
        // enable selection of the stackview and not just from its subviews
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded {
            self.didSelectSubject.send(())
        })
            .padding(.leading, .medium)
            .padding(.trailing, .medium)
    }
}

struct CanyonItemView_Previews: PreviewProvider {
    static var previews: some View {
        let result = SearchResult(name: "Moonflower", canyonDetails: Canyon.dummy())
        CanyonItemView(result: result)
    }
}
