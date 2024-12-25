//  Created by Brice Pollock for Canyoneer on 12/25/24

import SwiftUI

struct ImageButton: View {
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
            Image(uiImage: image.withRenderingMode(.alwaysTemplate))
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 24)
                .foregroundColor(ColorPalette.Color.action)
        })
    }
}

