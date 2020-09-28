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
        if movie.genreIDS.count > 0 {
            self.genre = GenresHelper.shared.genres[movie.genreIDS[0]]?.name ?? ""
        } else {
            self.genre = ""
        }
        self.overview = movie.overview
        let imagePath = movie.posterPath != nil ? movie.posterPath! : (movie.backdropPath ?? "")
        self.imageURL =  "\(TMDbURL.image)\(imagePath)"
        
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
