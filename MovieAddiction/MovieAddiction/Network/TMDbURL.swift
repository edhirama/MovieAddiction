//
//  URLConstants.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

enum APIVersion: String {
    case v3 = "/3"
}

struct TMDbURL {
    
    static let base = "api.themoviedb.org"
    static let image = "https://image.tmdb.org/t/p/w300"
    
    struct Movie {
        
        enum ParameterKey: String {
            case apiKey = "api_key"
            case language = "language"
            case page = "page"
            case region = "region"
        }
    }
}



