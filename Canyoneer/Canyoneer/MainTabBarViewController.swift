//
//  MainTabBarViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    enum Tab: CaseIterable {
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
    
    private static let map = MapViewController(type: .apple, canyons: [])
    private static let favorite = FavoriteViewController()
    private static let search = SearchViewController()
    
    public static func make() -> UIViewController {
        let controller = MainTabBarController()
        controller.setupTabs()
        controller.delegate = controller
        return controller
    }
        
    private var tabs: [Tab] {
        return Tab.allCases.sorted { $0.index < $1.index }
    }
    
    private func setupTabs() {
        self.viewControllers = self.tabs.map {
            let item = UITabBarItem(title: $0.title, image: $0.icon, selectedImage: nil)
            let controller = Self.controller(for: $0)
            controller.tabBarItem = item
            return UINavigationController(rootViewController: controller)
        }
    }
    
    private func switchTab(to tab: Tab) {
        self.selectedIndex = tab.index
    }
    
    static func controller(for tab: Tab) -> UIViewController {
        let root: UIViewController
        switch tab {
        case .map: root = Self.map
        case .favorites: root = Self.favorite
        case .search: root = Self.search
        }
        return root
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
}
