//
//  NetworkValidation.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation

func networkResponseHasError(url: URL, data: Data?, response: HTTPURLResponse, error: Error?) -> Bool {
    guard response.statusCode == 200 else {
        if let error = error {
            Global.logger.debug("Error for \(url): \(error.localizedDescription)")
        } else {
            Global.logger.debug("Unknown error for \(url) with code: \(response.statusCode) and data: \(data?.base64EncodedString() ?? ""))")
        }
        
        return true
    }
    return false
}
