//  Created by Brice Pollock for Canyoneer on 12/4/23

import Foundation
import SwiftUI

/// Generic converter from UIKit ot SwiftUI
struct AnyUIKitView: UIViewRepresentable {
    let view: UIView
    func makeUIView(context: Context) -> UIView {
        return view
    }
    func updateUIView(_ view: UIView, context: Context) { }
}
