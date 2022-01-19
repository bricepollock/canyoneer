//
//  WeatherService.swift
//  whereToClimb
//
//  Created by Brice Pollock on 12/10/18.
//  Copyright © 2018 Brice Pollock. All rights reserved.
//

import Foundation
import RxSwift

struct Response {
    let json: NSDictionary?
    let httpResponse: HTTPURLResponse?
    let error: Error?
}

class NetworkService {
    private let defaultSession: URLSession
    private var dataTasks: [String: URLSessionDataTask] = [:]
    
    init(additionalHeaders: [String: String] = [:]) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = additionalHeaders
        defaultSession = URLSession(configuration: config)
    }
    
    internal func cancelPriorTaskIfExists(key: String) {
        if let priorTask = dataTasks[key] {
            priorTask.cancel()
        }
    }
    
    internal func request(url: URL) -> Observable<Response> {
        return Observable.create { subscriber in
            let taskKey = url.absoluteString
            // all threads request the same url and therefore we cancel everything. Its a race condition
            //self.cancelPriorTaskIfExists(key: taskKey)
            let task = self.defaultSession.dataTask(with: url) { [weak self] (data, response, error) in
                defer { self?.dataTasks[taskKey] = nil }
                
                if response == nil {
                    Global.logger.debug("nil network response to \(url) with error: \(String(describing: error))")
                    subscriber.onNext(Response(json: nil, httpResponse: nil, error: error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    Global.logger.debug("Response not HTTPURLResponse!?!??")
                    subscriber.onNext(Response(json: nil,httpResponse: nil,error: error))
                    return
                }
                
                guard networkResponseHasError(url: url, data: data, response: httpResponse, error: error) == false else {
                    Global.logger.debug("Network Response Error: \(String(describing: error))")
                    subscriber.onNext(Response(json: nil, httpResponse: httpResponse, error: error))
                    return
                }
                
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {
                    Global.logger.debug("Unable to serialize response")
                    subscriber.onNext(Response(json: nil,httpResponse: httpResponse,error: error))
                    return
                }
                //            self.printDebugMessage(response)
                
                subscriber.onNext(Response(json: json, httpResponse: httpResponse, error: error))
            }
            
            task.resume()
            self.dataTasks[taskKey] = task
            return Disposables.create()
            }.catch({ (error) -> Observable<Response> in
                Global.logger.debug("Network Error! \(String(describing: error))")
                return Observable.just(Response(json: nil, httpResponse: nil, error: error))
            })
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

