//
//  Genre.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

struct Genre: Codable {
    let name: String
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case id = "id"
    }
}
