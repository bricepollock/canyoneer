//
//  StarQualityView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/29/23.
//

import Foundation
import SwiftUI

@MainActor
struct StarQualityViewModel {
    struct ImageStar: Identifiable {
        var id: String {
            String(quality)
        }
        let quality: Double
        let image: UIImage
    }
    
    public let images: [ImageStar]
    
    init(quality: Double) {
        images = Self.stars(quality: quality)
    }
    
    internal static func stars(quality: Double) -> [ImageStar] {
        var images = [ImageStar]()
        var remainingQuality = quality
        while remainingQuality > 0 {
            if remainingQuality >= 1 {
                images.append(ImageStar(quality: remainingQuality, image: Constants.fullImage))
            } else if remainingQuality >= 0.5 {
                images.append(ImageStar(quality: remainingQuality, image: Constants.halfImage))
            } // else no star because less than 0.5
            remainingQuality -= 1
        }
        return images
    }
    
    enum Constants {
        static let fullImage = UIImage(named: "emj_star_full")!
        static let halfImage = UIImage(named: "emj_star_half")!
    }
}

struct StarQualityView: View {
    let viewModel: StarQualityViewModel
    
    var body: some View {
        VStack {
            Spacer()
            LazyHStack {
                ForEach(viewModel.images) {
                    Image(uiImage: $0.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
            }
            Spacer()
        }
    }
}
