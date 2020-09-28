//
//  UpcomingMoviesEndpoint.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 28/09/20.
//  Copyright © 2020 Edgar. All rights reserved.
//

import Foundation

struct UpcomingMoviesEndpoint: Endpoint {
    var apiVersion: APIVersion { .v3 }
    var method: HTTPMethod { .GET }
    var path: String { "\(apiVersion.rawValue)/movie/upcoming" }
}

struct GenresEndpoint: Endpoint {
    var apiVersion: APIVersion { .v3 }
    var method: HTTPMethod { .GET }
    var path: String { "\(apiVersion.rawValue)/genre/movie/list" }
}
