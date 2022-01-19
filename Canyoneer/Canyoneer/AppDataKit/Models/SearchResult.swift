//
//  SearchResult.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct SearchResult {
    let name: String
    let canyonDetails: Canyon
}

struct SearchResultList {
    let searchString: String
    let result: [SearchResult]
}


