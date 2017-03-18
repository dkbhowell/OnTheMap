//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/17/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

class UdacityClient {
    
    let httpSession = URLSession.shared
    
    func login(username: String, password: String) {
        var body = [String:Any]()
        var udacityDict = [String:String]()
        udacityDict[RequestParamNames.USERNAME] = username
        udacityDict[RequestParamNames.PASSWORD] = password
        body[RequestParamNames.UDACITY] = udacityDict
        
        _ = taskForPOST(Methods.SESSION, params: nil, jsonDataForBody: body) { (result) in
            switch result {
            case .success(let value):
                let dataValue = value as! Data
                let stringValue = String(data: dataValue, encoding: .utf8)!
                print(stringValue)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // Task Execution Methods
    
    func taskForGET(_ method: String, params: [String:Any]?, completion: @escaping (_ result: HttpResult) -> Void) -> URLSessionDataTask {
        
        let url = udacityUrlFromParams(params, withPathExtension: method)
        print("URL: \(url)")
        let request = URLRequest(url: url)
        
        let task = httpSession.dataTask(with: request) { (data, resp, err) in
            let result = self.validateHttpResponse(data: data, response: resp, error: err)
            completion(result)
        }
        
        task.resume()
        return task
    }
    
    func taskForPOST(_ method: String, params: [String:Any]?, jsonDataForBody data: [String:Any]?, completion: @escaping (_ result: HttpResult) -> Void) -> URLSessionDataTask {
        
        let url = udacityUrlFromParams(params, withPathExtension: method)
        print("URL: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let data = data {
            let body = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = body
            let bodyString = String(data:body!, encoding: .utf8)
            print("JSON Body: \n\(bodyString!)")
        }
        
        let task = httpSession.dataTask(with: request) { (data, resp, err) in
            let result = self.validateHttpResponse(data: data, response: resp, error: err)
            completion(result)
        }
        
        task.resume()
        return task
    }
    
    // Helper Methods
    func udacityUrlFromParams(_ params: [String:Any]? = nil, withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = UrlComponents.SCHEME
        components.host = UrlComponents.HOST
        components.path = UrlComponents.PATH + (withPathExtension ?? "")
        
        if let params = params {
            components.queryItems = [URLQueryItem]()
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    func validateHttpResponse(data: Data?, response: URLResponse?, error: Error?) -> HttpResult {
        if let data = data {
            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            return HttpResult.success(newData)
        }
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        return HttpResult.failure(AppError.NetworkingError(domain: "Udacity", description: "Response Code: \(responseCode) Error: \(error)"))
    }
    
    
    // Singleton
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
