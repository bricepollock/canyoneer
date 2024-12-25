//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import SwiftUI

/// Image Button used on the map
struct MapButton: View {
    private let image: UIImage
    private let action: () -> Void
    
    init(system name: String, action: @escaping () -> Void) {
        self.image = UIImage(systemName: name)!.withRenderingMode(.alwaysTemplate)
        self.action = action
    }
    
    init(image: UIImage, action: @escaping () -> Void) {
        self.image = image.withRenderingMode(.alwaysTemplate)
        self.action = action
    }
    
    @ViewBuilder
    var body: some View {
        Button(action: action, label: {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(ColorPalette.GrayScale.dark, lineWidth: 1)
                    .background(ColorPalette.Color.canyonTan)
                    .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                Image(uiImage: image.withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.imageSize, height: Constants.imageSize)
                    .foregroundColor(ColorPalette.GrayScale.dark)
            }
        })
    }
    
    enum Constants {
        static let imageSize: CGFloat = 20
        static let buttonSize: CGFloat = 30
    }
}

