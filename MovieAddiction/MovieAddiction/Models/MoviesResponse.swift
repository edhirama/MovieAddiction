//
//  TMDbResponse.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

struct MoviesResponse: Codable {
    let results: [Movie]
    let page, totalResults: Int
    let dates: Dates
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
        case page = "page"
        case totalResults = "total_results"
        case dates = "dates"
        case totalPages = "total_pages"
    }
}

struct Dates: Codable {
    let maximum, minimum: String
    
    enum CodingKeys: String, CodingKey {
        case maximum = "maximum"
        case minimum = "minimum"
    }
}
