//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/30/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class ParseClient {
    // Singleton
    static let sharedInstance = ParseClient()
    private let httpClient = URLSession.shared
    
    // helper functions
    
    private func getTask(method: String, params: [String:Any]) -> URLSessionDataTask {
        let url = buildURL(params: params, withPathExtension: method)
        let request = URLRequest(url: url)
        
        let task = httpClient.dataTask(with: request) { (data, resp, err) in
            // TO-DO
        }
        
        task.resume()
        return task
    }
    
    private func buildURL(params: [String:Any]? = nil, withPathExtension pathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = UrlComponents.SCHEME
        components.host = UrlComponents.HOST
        components.path = UrlComponents.PATH + (pathExtension ?? "")
        
        if let params = params {
            components.queryItems = [URLQueryItem]()
            for param in params {
                let key = param.key
                let value = "\(param.value)"
                let queryItem = URLQueryItem(name: key, value: value)
                components.queryItems?.append(queryItem)
            }
        }
        return components.url!
    }
    
    private func validateResponse(data: Data?, resp: URLResponse?, err: Error?) -> HttpResult<Data, AppError> {
        if let data = data {
            return .success(data)
        }
        
        guard let statusCode = (resp as? HTTPURLResponse)?.statusCode else {
            return .failure(AppError.UnexpectedResult(domain: "Parse Client", description: "No Status Code in Response"))
        }
        
        guard let err = err else {
            return .failure(AppError.UnexpectedResult(domain: "Parse Client", description: "No Data, No Error in Response"))
        }
        
        return .failure(AppError.NetworkingError(domain: "Parse Client", description: "Status Code: \(statusCode) \nError: \(err)"))
    }
    
}
