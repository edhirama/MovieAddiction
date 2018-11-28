//
//  GenresListService.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

class GenresListService {
    
    static func retrieveList(completion: ((Result<[Genre]>) -> Void)?) {
        let queryItems = [URLQueryItem(name: TMDbURL.Movie.ParameterKey.apiKey.rawValue, value: "1f54bd990f1cdfb230adb312546d765d")]
        
        NetworkRequestImplementation.request(type: .get, host: TMDbURL.base, path: TMDbURL.Genre.Movie.list, queryItems: queryItems) { (result) in
            switch (result) {
            case .failure(let error):
                completion?(.failure(error))
                break
            case .success(let data):
                
                let decoder = JSONDecoder()
                do {
                    let response  = try decoder.decode(GenresResponse.self, from: data)
                    completion?(.success(response.genres))
                } catch {
                    completion?(.failure(error))
                }
                break
            }
        }
    }
    
}
