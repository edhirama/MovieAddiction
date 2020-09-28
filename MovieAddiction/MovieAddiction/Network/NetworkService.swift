//
//  NetworkRequest.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

enum APIError: Error {
    case malformedURL
    case invalidResponseData
}

protocol NetworkService {
   func performRequest(bodyArguments: [String: Any]?, completionHandler: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void))
    func performRequest(completionHandler: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void))
}

final class HTTPService: NetworkService {
    var endpoint: Endpoint
    private var urlSessionTask: URLSessionDataTask?

    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    func performRequest(completionHandler: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)) {
        performRequest(bodyArguments: nil, completionHandler: completionHandler)
    }

    func performRequest(bodyArguments: [String: Any]? = nil, completionHandler: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)) {

        let session: URLSession = URLSession(configuration: .default)
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        urlComponents.queryItems = makeQueryItems(fromEndpoint: endpoint)
        
        guard let url = urlComponents.url else {
            completionHandler(.failure(APIError.malformedURL))
            return
        }

        urlSessionTask = session.dataTask(with: makeRequest(fromURL: url, withAdditionalBodyArguments: bodyArguments)) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
            } else if
                let response = response as? HTTPURLResponse,
                let data = data
                {
                completionHandler(.success((data, response)))
            }
        }
        urlSessionTask?.resume()
    }

    private func makeQueryItems(fromEndpoint endpoint: Endpoint) -> [URLQueryItem]? {
        guard let queryArguments = endpoint.queryArguments else { return nil }
        var queryItems: [URLQueryItem] = .init()
        for queryItem in queryArguments {
            queryItems.append(URLQueryItem(name: queryItem.key, value: queryItem.value))
        }
        return queryItems
    }

    private func makeRequest(fromURL url: URL, withAdditionalBodyArguments additionalBodyArguments: [String: Any]?) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        addHeaders(toRequest: &urlRequest, withEndpoint: endpoint)
        if let bodyArguments = makeBody(withEndpoint: endpoint, andAdditionalArguments: additionalBodyArguments) {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyArguments, options: [])
        }
        return urlRequest
    }

    private func addHeaders(toRequest urlRequest: inout URLRequest, withEndpoint endpoint: Endpoint) {
        for (key, value) in endpoint.headers {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
    }

    private func makeBody(withEndpoint endpoint: Endpoint, andAdditionalArguments additionalArguments: [String: Any]?) -> [String: Any]? {
        var body = [String: Any]()
        if let bodyArguments = endpoint.bodyArguments {
            body.merge(bodyArguments)
        }
        if let additionalBodyArguments = additionalArguments {
            body.merge(additionalBodyArguments)
        }
        return body.isEmpty ? nil : body
    }
}

extension Dictionary {
    mutating func merge(_ dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
