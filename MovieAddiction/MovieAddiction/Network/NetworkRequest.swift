//
//  NetworkRequest.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

protocol NetworkRequest {
    static func request(type: RequestType, host:String, path: String, queryItems: [URLQueryItem], completion:  ((Result<Data>) -> Void)?)
}

class NetworkRequestImplementation: NetworkRequest {
    
    
    static func request(type: RequestType, host:String, path: String, queryItems: [URLQueryItem], completion:  ((Result<Data>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    completion?(.success(jsonData))
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    
}
