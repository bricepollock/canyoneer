//
//  QueryResult.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

/// A result list item for a canyon from a query (map, search, etc.)
struct QueryResult: Identifiable {
    let name: String
    let canyonDetails: CanyonIndex
    
    var id: String {
        canyonDetails.id
    }
}

/// Full result list for a query (map, search, etc.)
struct QueryResultList {
    let searchString: String
    let results: [QueryResult]
}


