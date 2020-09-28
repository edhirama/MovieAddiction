//
//  UpcomingMoviesService.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

protocol UpcomingMoviesProvider {
    func retrieveList(page: Int, completion: @escaping ((Result<MoviesResponse, Error>) -> Void))
}

final class RemoteUpcomingMoviesProvider: UpcomingMoviesProvider {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func retrieveList(page: Int, completion: @escaping ((Result<MoviesResponse, Error>) -> Void)) {
        networkService.performRequest { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                break
            case .success(let result):

                let decoder = JSONDecoder()
                do {
                    let response  = try decoder.decode(MoviesResponse.self, from: result.0)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
                break
            }
        }
    }
}
