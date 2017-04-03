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
    
    func getStudents(completion: @escaping (DataResult<[UdacityStudent], AppError>) -> () ) {
        let params = [
            RequestParamaterNames.LIMIT: 100
        ]
        _ = runGetTask(method: "StudentLocation", params: params) { (networkResult) in
            switch networkResult {
            case .success(let data):
                
                guard let parseResult: [String:Any] = self.parse(data: data) else {
                    completion(.failure(.ParseError(domain: "Parse Client", description: "Error parsing data into JSON")))
                    return
                }
                guard let results = parseResult[ResponseKeys.RESULTS] as? [[String:Any]] else {
                    completion(.failure(.ParseError(domain: "Parse Client", description: "Error retrieving value for key: '\(ResponseKeys.RESULTS)' from dict: \(parseResult)")))
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
                    print("Found \(results.count) results for student with id \(id)")
                    let firstStudent = results[0]
                    if let student = UdacityStudent(dictionary: firstStudent) {
                        completion(.success(student))
                    }
                }
                
                completion(.success((nil)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func runGetTask(method: String, params: [String:Any], completion: @escaping (DataResult<Data, AppError>) -> () ) -> URLSessionDataTask {
        let url = buildURL(params: params, withPathExtension: method)
        print("Parse URL: \(url)")
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
    
    private func validateResponse(data: Data?, resp: URLResponse?, err: Error?) -> DataResult<Data, AppError> {
        if let data = data {
            return .success(data)
        }
        
        guard let err = err else {
            return .failure(AppError.UnexpectedResult(domain: "Parse Client", description: "No Data, No Error in Response"))
        }
        
        let statusCode = ((resp as? HTTPURLResponse)?.statusCode).map { "\($0)" } ?? "None"
        
        return .failure(AppError.NetworkingError(domain: "Parse Client", description: "Status Code: \(statusCode) \nError: \(err)"))
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
