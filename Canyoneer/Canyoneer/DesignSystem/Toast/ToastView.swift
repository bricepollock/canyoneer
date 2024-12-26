//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import SwiftUI

struct ToastView: View {
    @Environment(\.toastMessage) var toastMessage
    
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            Group {
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.GrayScale.white)
                    .font(FontBook.Body.regular)
                    .padding(8)
            }
            .background(ColorPalette.GrayScale.black.opacity(0.5))
            .cornerRadius(8)
            .onTapGesture {
                toastMessage.wrappedValue = nil
            }
            .onAppear {
                Task(priority: .userInitiated) { @MainActor in
                    try? await Task.sleep(nanoseconds: Constants.duration * 1_000_000_000)
                    toastMessage.wrappedValue = nil
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 52)
    }
    
    enum Constants {
        static let duration: UInt64 = 2
    }
}
