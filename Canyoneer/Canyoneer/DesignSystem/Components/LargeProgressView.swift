//  Created by Brice Pollock for Canyoneer on 12/2/23

import SwiftUI

struct LargeProgressView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                    .frame(width: 40, height: 40)
                Spacer()
            }
            Spacer()
        }
    }
}
