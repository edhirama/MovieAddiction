//
//  URLConstants.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

struct TMDbURL {
    
    static let base = "api.themoviedb.org"
    static let version = "/3"
    
    struct Movie {
        static let upcoming = "\(version)/movie/upcoming"
        
        enum ParameterKey: String {
            case apiKey = "api_key"
            case language = "language"
            case page = "page"
            case region = "region"
        }
    }
    
    struct Genre {
        
        struct Movie {
            static let list = "\(version)/genre/movie/list"
        }
    }
}



