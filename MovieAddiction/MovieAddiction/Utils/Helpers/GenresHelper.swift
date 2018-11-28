//
//  GenresHelper.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 28/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

class GenresHelper {
    
    static let shared: GenresHelper = {
        let instance = GenresHelper()
        return instance
    }()
    
    var genres = [Int: Genre]()
    
    func retrieveGenres(completion: @escaping () -> Void) {
        GenresListService.retrieveList { (result) in
            switch result {
            case .failure(let error):
                completion()
                print(error.localizedDescription)
                break
            case .success(let genres):
                for genre in genres {
                    self.genres[genre.id] = genre
                }
                completion()
                break
            }
        }
    }
    
}
