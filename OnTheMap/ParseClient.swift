//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/30/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class ParseClient {
    static let shared = ParseClient()
    private let httpClient = URLSession.shared
    
    // MARK: Parse API Calls
    func getStudents(completion: @escaping (DataResult<[UdacityStudent], AppError>) -> () ) {
        let params = [
            RequestParamaterNames.LIMIT: 100
        ]
        _ = runGetTask(method: "StudentLocation", params: params) { (networkResult) in
            switch networkResult {
            case .success(let data):
                
                guard let parseResult: [String:Any] = self.parse(data: data) else {
                    let error = AppError.ParseError(domain: "Parse Client", description: "Error parsing data into JSON")
                    completion(.failure(error))
                    return
                }
                guard let results = parseResult[ResponseKeys.RESULTS] as? [[String:Any]] else {
                    let error = AppError.ParseError(domain: "Parse Client", description: "Error retrieving value for key: '\(ResponseKeys.RESULTS)' from dict: \(parseResult)")
                    completion(.failure(error))
                    return
                }
                
                var students = [UdacityStudent]()
                for studentDict in results {
                    // REQUIRED
                    if let newStudent = UdacityStudent(dictionary: studentDict) {
                            students.append(newStudent)
                    }
                }
                completion(.success(students))
                
            case .failure(let appError):
                completion(.failure(appError))
            }
        }
    }
    
    func getStudent(withUdacityID id: String, completion: @escaping (DataResult<UdacityStudent?, AppError>) -> () ) {
        let whereClause = "{\"uniqueKey\":\"\(id)\"}"
        let params = [
            RequestParamaterNames.WHERE: whereClause
        ]
        
        _ = runGetTask(method: "StudentLocation", params: params) { (networkResult) in
            switch networkResult {
            case .success(let data):
                
                guard let parseResult: [String:Any] = self.parse(data: data) else {
                    completion(.failure(.ParseError(domain:"Parse Client", description: "Error parsing data into JSON")))
                    return
                }
                guard let results = parseResult[ResponseKeys.RESULTS] as? [[String:Any]] else {
                    completion(.failure(.ParseError(domain:"Parse Client", description: "Error: Key '\(ResponseKeys.RESULTS)' not found in dict: \(parseResult)")))
                    return
                }
                
                if results.count > 0 {
                    print("Found \(results.count) results for student with id \(id) -- Using First One")
                    let firstStudent = results[0]
                    if let student = UdacityStudent(dictionary: firstStudent) {
                        completion(.success(student))
                        return
                    } else {
                        completion(.success((nil)))
                    }
                } else {
                    completion(.success(nil))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func postStudentLocation(lat: Double, lng: Double, data: String, completion: @escaping (DataResult<String, AppError>) -> () ) {
        if let user = StateController.shared.getUser() {
            let studentDict = UdacityStudent.studentDict(fromUser: user, lat: lat, lng: lng, data: data)
            
            _ = runPostTask(method: "StudentLocation", bodyData: studentDict, completion: { (result) in
                switch result {
                case .success(let data):
                    guard let successObj = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
                        completion(.failure(.ParseError(domain: "Parse Client", description: "Error converting data to JSON Object")))
                        return
                    }
                    guard let objectId = successObj[ResponseKeys.OBJECT_ID] as? String else {
                        completion(.failure(.ParseError(domain: "Parse Client", description: "Key '\(ResponseKeys.OBJECT_ID)' Not found in dict: \(successObj)")))
                        return
                    }
                    completion(.success(objectId))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } else {
            completion(.failure(.UnexpectedResult(domain: "Parse Client", description: "No User Found in Model")))
        }
    }
    
    func updateStudentLocation(objectId: String, lat: Double, lng: Double, data: String, completion: @escaping (DataResult<String, AppError>) -> () ) {
        if let user = StateController.shared.getUser() {
            let studentDict = UdacityStudent.studentDict(fromUser: user, lat: lat, lng: lng, data: data)
            
            _ = runPutTask(method: "StudentLocation/\(objectId)", bodyData: studentDict, completion: { (result) in
                switch result {
                case .success(let data):
                    print(data)
                    guard let parsedResult = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
                        completion(.failure(.ParseError(domain: "Parse Client", description: "Error parsing result into JSON: \(data)")))
                        return
                    }
                    
                    guard let updatedTime = parsedResult[ResponseKeys.UPDATED_AT] as? String else {
                        completion(.failure(.ParseError(domain: "Parse Client", description: "Error finding key '\(ResponseKeys.UPDATED_AT)' in dict: \(parsedResult)")))
                        return
                    }
                    
                    completion(.success(updatedTime))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    
    // MARK: Helper methods
    private func runGetTask(method: String, params: [String:Any]? = nil, completion: @escaping (DataResult<Data, AppError>) -> () ) -> URLSessionDataTask {
        let url = buildURL(params: params, withPathExtension: method)
        print("Parse Get URL: \(url)")
        var request = URLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = httpClient.dataTask(with: request) { (data, resp, err) in
            // TO-DO
            let result = self.validateResponse(data: data, resp: resp, err: err)
            completion(result)
        }
        
        task.resume()
        return task
    }
    
    private func runPostTask(method: String, params: [String:Any]? = nil, bodyData: [String:Any], completion: @escaping (DataResult<Data,AppError>) -> () ) -> URLSessionDataTask {
        let url = buildURL(params: params, withPathExtension: method)
        print("Parse Post URL: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBodyData = try? JSONSerialization.data(withJSONObject: bodyData)
        request.httpBody = jsonBodyData
        
        let task = httpClient.dataTask(with: request) { (data, resp, err) in
            let result = self.validateResponse(data: data, resp: resp, err: err)
            completion(result)
        }
        
        task.resume()
        return task
    }
    
    private func runPutTask(method: String, params: [String:Any]? = nil, bodyData: [String:Any]? = nil, completion: @escaping (DataResult<Data,AppError>) -> () ) -> URLSessionDataTask {
        let url = buildURL(params: params, withPathExtension: method)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let bodyData = bodyData {
            let jsonBodyData = try? JSONSerialization.data(withJSONObject: bodyData)
            request.httpBody = jsonBodyData
        }
        
        let task = httpClient.dataTask(with: request) { (data, resp, err) in
            let result = self.validateResponse(data: data, resp: resp, err: err)
            completion(result)
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
    
    // returns the data from the http call or the appropriate error if something went wrong
    private func validateResponse(data: Data?, resp: URLResponse?, err: Error?) -> DataResult<Data, AppError> {
        if let data = data {
            return .success(data)
        }
        guard let err = err else {
            return .failure(AppError.UnexpectedResult(domain: "Parse Client", description: "No Data, No Error in Response"))
        }
        let statusCode = ((resp as? HTTPURLResponse)?.statusCode).map { "\($0)" } ?? "None"
        return .failure(AppError.NetworkError(domain: "Parse Client", description: "Status Code: \(statusCode) \nError: \(err)"))
    }
    
    private func parse(data: Data) -> [String:Any]? {
        guard let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
            return nil
        }
        return result
    }
    
    private func parse(data: Data) -> [[String:Any]]? {
        guard let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [[String:Any]] else {
            return nil
        }
        return result
    }
}
