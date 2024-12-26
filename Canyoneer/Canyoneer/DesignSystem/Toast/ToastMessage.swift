//  Created by Brice Pollock for Canyoneer on 12/25/24

import SwiftUI

struct ToastMessage: EnvironmentKey {
    static var defaultValue: Binding<String?> = .constant(nil)
}

extension EnvironmentValues {
    var toastMessage: Binding<String?> {
        get { self[ToastMessage.self] }
        set { self[ToastMessage.self] = newValue }
    }
}
