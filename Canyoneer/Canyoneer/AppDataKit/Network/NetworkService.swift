//
//  WeatherService.swift
//  whereToClimb
//
//  Created by Brice Pollock on 12/10/18.
//  Copyright © 2018 Brice Pollock. All rights reserved.
//

import Foundation

struct Response {
    let json: NSDictionary
    let httpResponse: HTTPURLResponse
}

class NetworkService {
    private let defaultSession: URLSession
    
    init(additionalHeaders: [String: String] = [:]) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = additionalHeaders
        defaultSession = URLSession(configuration: config)
    }
    
    internal func request(url: URL) async throws -> Response {
        let (data, response) = try await self.defaultSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Global.logger.debug("Response not HTTPURLResponse!?!??")
            throw RequestError.badResponse
        }
        
        guard httpResponse.statusCode < 300 && httpResponse.statusCode >= 200 else {
            Global.logger.debug("Unknown error for \(url) with code: \(httpResponse.statusCode) and data: \(data.base64EncodedString()))")
            throw RequestError.httpStatusCodeError
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {
            Global.logger.debug("Unable to serialize response")
            throw RequestError.serialization
        }
        //            self.printDebugMessage(response)
        
        return Response(json: json, httpResponse: httpResponse)
    }
//
//    private func printDebugMessage(alamoFireResponse: Response<AnyObject, NSError>) {
//        print(alamoFireResponse.request)  // original URL request
//        print(alamoFireResponse.response) // URL response
//        print(alamoFireResponse.data)     // server data
//        print(alamoFireResponse.result)   // result of response serialization
//
//        if let JSON = alamoFireResponse.result.value {
//            print("JSON: \(JSON)")
//        }
//    }
}

