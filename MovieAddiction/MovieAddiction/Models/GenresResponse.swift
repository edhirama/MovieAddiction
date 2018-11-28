//
//  GenresResponse.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

struct GenresResponse: Codable {
    
    let genres: [Genre]
    
    enum CodingKeys: String, CodingKey {
        case genres = "genres"
    }
}
