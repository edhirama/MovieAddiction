//
//  MovieViewModel.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 28/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

struct MovieViewModel {
    
    let title: String
    let genre: String
    let overview: String
    let imageURL: String
    let releaseDate: String
    
    init(movie: Movie) {
        self.title = movie.title
        self.genre = GenresHelper.shared.genres[movie.genreIDS[0]]?.name ?? ""
        self.overview = movie.overview
        self.imageURL = movie.posterPath != nil ? movie.posterPath! : (movie.backdropPath ?? "")
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let date = dateFormatterGet.date(from: movie.releaseDate) {
            self.releaseDate = dateFormatterPrint.string(from: date)
        } else {
            self.releaseDate = movie.releaseDate
        }
        
    }
}
