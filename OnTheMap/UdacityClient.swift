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
    
    // state
    var sessionId: String?
    var userId: String?
    var nickname: String?
    var lastName: String?
    var email: String?
    
    func authenticate(username: String, password: String, completionForAuth: @escaping (Result) -> () ) {
        login(username: username, password: password) { (result) in
            switch result {
            case .success(_):
                self.getUserInfo(userId: self.userId!, completionForUserInfo: { (result) in
                    switch result {
                    case .success(_):
                        completionForAuth(.success("Login Successful"))
                    case .failure(let description):
                        completionForAuth(.failure("Login Unsuccessful: \(description)"))
                    }
                })
            case .failure(let description):
                completionForAuth(.failure("Login Unsuccessful: \(description)"))
            }
        }
    }
    
    func login(username: String, password: String, completionForLogin: @escaping (Result) -> () ) {
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
                    completionForLogin(.failure("Error converting result to dict"))
                    return
                }
                
                guard let sessionData = result[ResponseKeys.SESSION] as? [String:Any] else {
                    completionForLogin(.failure("Error: No session data found in response"))
                    return
                }
                
                guard let accountData = result[ResponseKeys.ACCOUNT] as? [String:Any] else {
                    completionForLogin(.failure("Error: No account data found in response"))
                    return
                }
                
                guard let sessionId = sessionData[ResponseKeys.SESSION_ID] as? String else {
                    completionForLogin(.failure("error: Key named '\(ResponseKeys.SESSION_ID)' not found in response: \(sessionData)"))
                    return
                }
                
                guard let userId = accountData[ResponseKeys.USER_ID] as? String else {
                    completionForLogin(.failure("error: Key named '\(ResponseKeys.USER_ID)' not found in response: \(accountData)"))
                    return
                }
                
                guard let isRegistered = accountData[ResponseKeys.REGISTERED] as? Bool else {
                    completionForLogin(.failure("error: Key named '\(ResponseKeys.REGISTERED)' not found in response: \(accountData)"))
                    return
                }
                
                print("Login Success")
                print("---Session id: \(sessionId)")
                print("---User id: \(userId)")
                print("---registered: \(isRegistered)")
                self.sessionId = sessionId
                self.userId = userId
                
                completionForLogin(.success("Login Successful"))
                
            case .failure(let error):
                completionForLogin(.failure("Error with request: \(error)"))
            }
        }
    }
    
    func getUserInfo(userId: String, completionForUserInfo: @escaping (Result) -> () ) {
        let newMethod = Methods.USER + "/\(userId)"
        _ = taskForGET(newMethod, params: nil, completion: { (result) in
            switch result {
            case .success(let data):
                
//                self.prettyPrinted(dataAsJsonDict: data, doPrint: true)
                
                guard let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
                    completionForUserInfo(.failure("Error parsing JSON Data: \(data)"))
                    return
                }
                
                guard let userInfo = result[ResponseKeys.USER_INFO] as? [String:Any] else {
                    completionForUserInfo(.failure("Error - key '\(ResponseKeys.USER_INFO)' not found in Dict: \(result)"))
                    return
                }
                
                guard let nickname = userInfo[ResponseKeys.NICKNAME] as? String else {
                    completionForUserInfo(.failure("Error - key '\(ResponseKeys.NICKNAME)' not found in Dict: \(userInfo)"))
                    return
                }
                
                guard let lastName = userInfo[ResponseKeys.LAST_NAME] as? String else {
                    completionForUserInfo(.failure("Error - key '\(ResponseKeys.LAST_NAME)' not found in Dict: \(userInfo)"))
                    return
                }
                
                guard let emailObj = userInfo[ResponseKeys.EMAIL] as? [String:Any] else {
                    completionForUserInfo(.failure("Error - key '\(ResponseKeys.EMAIL)' not found in Dict: \(userInfo)"))
                    return
                }
                
                guard let email = emailObj[ResponseKeys.EMAIL_ADDRESS] as? String else {
                    completionForUserInfo(.failure("Error - key '\(ResponseKeys.EMAIL_ADDRESS)' not found in Dict: \(emailObj)"))
                    return
                }
                
                print("User Info Success:")
                print("---Nickname: \(nickname)")
                print("---Last Name: \(lastName)")
                print("---Email: \(email)")
                self.nickname = nickname
                self.lastName = lastName
                self.email = email
                
                completionForUserInfo(.success("User Info Fetched Successfully"))
                
            case .failure(let error):
                completionForUserInfo(.failure("Error with request: \(error)"))
            }
        })
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
        
        guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {
            return .failure(AppError.UnexpectedResult(domain: "Udacity", description: "No response code in response"))
        }
        
        guard let error = error else {
            return .failure(AppError.UnexpectedResult(domain: "Udacity", description: "Error is nil"))
        }
        
        return .failure(AppError.NetworkingError(domain: "Udacity", description: "Response Code: \(responseCode) Error: \(error)"))
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
