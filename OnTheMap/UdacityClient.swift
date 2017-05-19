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
    
    let state = StateController.sharedInstance
    var sessionId: String?
    
    func authenticate(username: String, password: String, completionForAuth: @escaping (Result) -> () ) {
        login(username: username, password: password) { (result) in
            switch result {
            case .success(let userId):
                self.getUserInfo(userId: userId, completionForUserInfo: { (result) in
                    switch result {
                    case .success(let user):
                        self.state.setUser(user: user)
                        completionForAuth(.success("Login Successful"))
                    case .failure(let description):
                        self.reset()
                        completionForAuth(.failure("Login Unsuccessful: \(description)"))
                    }
                })
            case .failure(let description):
                self.reset()
                completionForAuth(.failure("Login Unsuccessful: \(description)"))
            }
        }
    }
    
    func login(username: String, password: String, completionForLogin: @escaping (DataResult<String, AppError>) -> () ) {
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
                    completionForLogin(.failure(.ParseError(domain: "UdacityClient", description: "Error converting result to dict")))
                    return
                }
                
                guard let sessionData = result[ResponseKeys.SESSION] as? [String:Any] else {
                    completionForLogin(.failure(.ParseError(domain: "UdacityClient", description: "Error: No session data found in response")))
                    return
                }
                
                guard let accountData = result[ResponseKeys.ACCOUNT] as? [String:Any] else {
                    completionForLogin(.failure(.ParseError(domain: "UdacityClient", description: "Error: No account data found in response")))
                    return
                }
                
                guard let sessionId = sessionData[ResponseKeys.SESSION_ID] as? String else {
                    completionForLogin(.failure(.ParseError(domain: "UdacityClient", description: "error: Key named '\(ResponseKeys.SESSION_ID)' not found in response: \(sessionData)")))
                    return
                }
                
                guard let userId = accountData[ResponseKeys.USER_ID] as? String else {
                    completionForLogin(.failure(.ParseError(domain: "UdacityClient", description: "error: Key named '\(ResponseKeys.USER_ID)' not found in response: \(accountData)")))
                    return
                }
                
                guard let isRegistered = accountData[ResponseKeys.REGISTERED] as? Bool else {
                    completionForLogin(.failure(.ParseError(domain: "UdacityClient", description: "error: Key named '\(ResponseKeys.REGISTERED)' not found in response: \(accountData)")))
                    return
                }
                
                print("Login Success")
                print("---Session id: \(sessionId)")
                print("---User id: \(userId)")
                print("---registered: \(isRegistered)")
                self.sessionId = sessionId
                
                completionForLogin(.success(userId))
                
            case .failure(let error):
                completionForLogin(.failure(.NetworkingError(domain: "UdacityClient", description: "Error with request: \(error)")))
            }
        }
    }
    
    func getUserInfo(userId: String, completionForUserInfo: @escaping (DataResult<User, AppError>) -> () ) {
        let newMethod = Methods.USER + "/\(userId)"
        _ = taskForGET(newMethod, params: nil, completion: { (result) in
            switch result {
            case .success(let data):
                guard let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
                    completionForUserInfo(.failure(.ParseError(domain: "UdacityClient", description: "Error parsing JSON Data: \(data)")))
                    return
                }
                if let newUser = User(dictionary: result) {
                    completionForUserInfo(.success(newUser))
                } else {
                    completionForUserInfo(.failure(.ParseError(domain: "UdacityClient", description: "Error parsing data into user")))
                }
            case .failure(let error):
                completionForUserInfo(.failure(.NetworkingError(domain: "UdacityClient", description: "Error with request: \(error)")))
            }
        })
    }
    
    // Task Execution Methods
    
    func taskForGET(_ method: String, params: [String:Any]?, completion: @escaping (_ result: DataResult<Data, AppError>) -> Void) -> URLSessionDataTask {
        
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
    
    func taskForPOST(_ method: String, params: [String:Any]?, jsonDataForBody data: [String:Any]?, completion: @escaping (_ result: DataResult<Data, AppError>) -> Void) -> URLSessionDataTask {
        
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
    
    func validateHttpResponse(data: Data?, response: URLResponse?, error: Error?) -> DataResult<Data, AppError> {
        if let data = data {
            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            return .success(newData)
        }
        
        guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {
            return .failure(AppError.UnexpectedResult(domain: "Udacity", description: "No response code in response"))
        }
        
        guard let error = error else {
            return .failure(AppError.UnexpectedResult(domain: "Udacity", description: "Error is nil"))
        }
        
        return .failure(AppError.NetworkingError(domain: "Udacity", description: "Response Code: \(responseCode) Error: \(error)"))
    }
    
    func reset() {
        sessionId = nil
    }
    
    func prettyPrinted(dataAsJsonDict data: Data, doPrint:Bool = false) -> String {
        guard let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
            if doPrint{
                print("Error parsing JSON Data: \(data)")
            }
            return "Error parsing JSON Data: \(data)"
        }
        
        guard let prettyData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
            if doPrint {
                print("Error serializing dictionary into Data")
            }
            return "Error serializaing dictionary into Data"
        }
        
        let prettyString = String(data: prettyData, encoding: .utf8)!
        if doPrint {
            print(prettyString)
        }
        return prettyString
    }
    
    
    // Singleton
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
