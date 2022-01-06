//
//  SearchResult.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

enum SearchResultType {
    case canyon
    case region
}

/// Search result can be a canyon or a region
struct SearchResult {
    let name: String
    let type: SearchResultType
    let canyonDetails: Canyon?
    let regionDetails: Region?
}

struct SearchResultList {
    let searchString: String
    let result: [SearchResult]
}


