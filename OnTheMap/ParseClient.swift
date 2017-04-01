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
    
    func getStudents(completion: @escaping (DataResult<[UdacityStudent]>) -> () ) {
        let params = [
            RequestParamaterNames.LIMIT: 100
        ]
        _ = runGetTask(method: "StudentLocation", params: params) { (networkResult) in
            switch networkResult {
            case .success(let data):
                let parseResult = self.parse(data: data)
                switch parseResult {
                case .success(let students):
                    completion(.success(students))
                case .failure(let appError):
                    completion(.failure("\(appError)"))
                }
            case .failure(let appError):
                completion(.failure("\(appError)"))
            }
        }
    }
    
    private func runGetTask(method: String, params: [String:Any], completion: @escaping (HttpResult<Data, AppError>) -> () ) -> URLSessionDataTask {
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
    
    private func validateResponse(data: Data?, resp: URLResponse?, err: Error?) -> HttpResult<Data, AppError> {
        if let data = data {
            return .success(data)
        }
        
        guard let err = err else {
            return .failure(AppError.UnexpectedResult(domain: "Parse Client", description: "No Data, No Error in Response"))
        }
        
        let statusCode = ((resp as? HTTPURLResponse)?.statusCode).map { "\($0)" } ?? "None"
        
        return .failure(AppError.NetworkingError(domain: "Parse Client", description: "Status Code: \(statusCode) \nError: \(err)"))
    }
    
    private func parse(data: Data) -> HttpResult<[UdacityStudent], AppError> {
        guard let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
            return .failure(.ParseError(domain: "Parse Client", description: "Error converting data to JSON"))
        }
        
        guard let results = result[ResponseKeys.RESULTS] as? [[String:Any]] else {
            return .failure(.ParseError(domain: "Parse Client", description: "Error retrieving value for key: '\(ResponseKeys.RESULTS)' from dict: \(result)"))
        }
        
        var students = [UdacityStudent]()
        for studentDict in results {
            // REQUIRED
            guard let objectId = studentDict[ResponseKeys.OBJECT_ID] as? String else {
                print("Error finding student key '\(ResponseKeys.OBJECT_ID)' in \(studentDict)")
                continue
            }
            guard let firstName = studentDict[ResponseKeys.FIRST_NAME] as? String else {
                print("Error finding student key '\(ResponseKeys.FIRST_NAME)' in \(studentDict)")
                continue
            }
            guard let lastName = studentDict[ResponseKeys.LAST_NAME] as? String else {
                print("Error finding student key '\(ResponseKeys.LAST_NAME)' in \(studentDict)")
                continue
            }
            guard let lat = studentDict[ResponseKeys.LAT] as? Double else {
                print("Error finding student key '\(ResponseKeys.LAT)' in \(studentDict)")
                continue
            }
            guard let lng = studentDict[ResponseKeys.LNG] as? Double else {
                print("Error finding student key '\(ResponseKeys.LNG)' in \(studentDict)")
                continue
            }
            
            // OPTIONAL
            let mapString = studentDict[ResponseKeys.MAP_STRING] as? String
            let mediaUrl = studentDict[ResponseKeys.MEDIA_URL] as? String
            let uniqueKey = studentDict[ResponseKeys.UNIQUE_KEY] as? String
            let updatedAt = studentDict[ResponseKeys.UPDATED_AT] as? String
            let createdAt = studentDict[ResponseKeys.CREATED_AT] as? String
            
            let newStudent = UdacityStudent(id: objectId, firstName: firstName, lastName: lastName, email: nil, data: mediaUrl)
            newStudent.data = mediaUrl
            newStudent.setLocationMarker(lat: lat, lng: lng)
            students.append(newStudent)
        }
        
        return .success(students)
        
    }
    
    
    
    
    
    
    
    
    
}
