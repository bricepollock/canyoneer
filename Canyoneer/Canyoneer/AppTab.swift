//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import SwiftUI

enum AppTab: CaseIterable {
    case map
    case favorites
    case search
    
    var index: Int {
        switch self {
        case .favorites: return 0
        case .map: return 1
        case .search: return 2
        }
    }
    
    var icon: UIImage {
        switch self {
        case .map: return UIImage(systemName: "map")!
        case .favorites: return UIImage(systemName: "star")!
        case .search: return UIImage(systemName: "magnifyingglass")!
        }
    }
    
    var title: String {
        switch self {
        case .map: return "Map"
        case .favorites: return "Favorites"
        case .search: return "Search"
        }
    }
}

struct CurrentTabKey: EnvironmentKey {
    static var defaultValue: Binding<AppTab> = .constant(.favorites)
}

extension EnvironmentValues {
    var currentTab: Binding<AppTab> {
        get { self[CurrentTabKey.self] }
        set { self[CurrentTabKey.self] = newValue }
    }
}
