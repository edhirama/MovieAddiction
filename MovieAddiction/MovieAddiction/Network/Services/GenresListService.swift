//
//  GenresListService.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

class GenresListService {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func retrieveList(completion: @escaping ((Result<[Genre], Error>) -> Void)) {
        networkService.performRequest { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let result):
                let decoder = JSONDecoder()
                do {
                    let response  = try decoder.decode(GenresResponse.self, from: result.0)
                    completion(.success(response.genres))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
}
