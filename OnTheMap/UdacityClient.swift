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
            case .success(let data):
                let stringValue = String(data: data, encoding: .utf8)!
                print(stringValue)
                guard let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
                    print("Error converting result to dict")
                    return
                }
                
                guard let sessionData = result[ResponseKeys.SESSION] as? [String:Any] else {
                    print("Error: No session data found in response")
                    return
                }
                
                guard let accountData = result[ResponseKeys.ACCOUNT] as? [String:Any] else {
                    print("Error: No account data found in response")
                    return
                }
                
                print("Session Data: \n\(sessionData)")
                print("Account Data: \n\(accountData)")
                
                guard let sessionId = sessionData[ResponseKeys.SESSION_ID] as? String else {
                    print("error: Key named '\(ResponseKeys.SESSION_ID)' not found in response: \(sessionData)")
                    return
                }
                
                guard let userId = accountData[ResponseKeys.USER_ID] as? String else {
                    print("error: Key named '\(ResponseKeys.USER_ID)' not found in response: \(accountData)")
                    return
                }
                
                guard let isRegistered = accountData[ResponseKeys.REGISTERED] as? Bool else {
                    print("error: Key named '\(ResponseKeys.REGISTERED)' not found in response: \(accountData)")
                    return
                }
                
                print("Login Success")
                print("---Session id: \(sessionId)")
                print("---User id: \(userId)")
                print("---registered: \(isRegistered)")
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // Task Execution Methods
    
    func taskForGET(_ method: String, params: [String:Any]?, completion: @escaping (_ result: HttpResult<Data, AppError>) -> Void) -> URLSessionDataTask {
        
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
    
    func taskForPOST(_ method: String, params: [String:Any]?, jsonDataForBody data: [String:Any]?, completion: @escaping (_ result: HttpResult<Data, AppError>) -> Void) -> URLSessionDataTask {
        
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
    
    func validateHttpResponse(data: Data?, response: URLResponse?, error: Error?) -> HttpResult<Data, AppError> {
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
