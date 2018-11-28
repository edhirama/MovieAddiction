//
//  UpcomingMoviesService.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

class UpcomingMoviesService {
    
    static func retrieveList(page: Int, completion: ((Result<MoviesResponse>) -> Void)?) {
        let queryItems = [URLQueryItem(name: TMDbURL.Movie.ParameterKey.apiKey.rawValue, value: "1f54bd990f1cdfb230adb312546d765d"),
            URLQueryItem(name: TMDbURL.Movie.ParameterKey.page.rawValue, value: String(page))]
        
        NetworkRequestImplementation.request(type: .get, host: TMDbURL.base, path: TMDbURL.Movie.upcoming, queryItems: queryItems) { (result) in
            switch (result) {
            case .failure(let error):
                completion?(.failure(error))
                break
            case .success(let data):
                
                let decoder = JSONDecoder()
                do {
                    let response  = try decoder.decode(MoviesResponse.self, from: data)
                    completion?(.success(response))
                } catch {
                    completion?(.failure(error))
                }
                break
            }
        }
    }
}
