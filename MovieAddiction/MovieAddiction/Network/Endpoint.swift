//
//  Endpoint.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 28/09/20.
//  Copyright © 2020 Edgar. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

protocol Endpoint {
    var apiVersion: APIVersion { get }
    var host: String { get }
    var bodyArguments: [String: Any]? { get }
    var queryArguments: [String: String]? { get }
    var headers: [String: String] { get }
    var method: HTTPMethod { get }
    var scheme: String { get }
    var path: String { get }
}

extension Endpoint {
    var scheme: String { "https" }
    var host: String { TMDbURL.base }

    var headers: [String : String] {
        ["Content-Type": "application/json",
         "Accept": "application/json"]
    }
    var queryArguments: [String: String]? {
        [TMDbURL.Movie.ParameterKey.apiKey.rawValue: "1f54bd990f1cdfb230adb312546d765d"] }
    var bodyArguments: [String : Any]? { nil }
}
