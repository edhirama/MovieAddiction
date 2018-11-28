//
//  UpcomingMoviesTableViewCell.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import UIKit

class UpcomingMoviesTableViewCell: UITableViewCell, Reusable, NibLoadableView {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    @IBOutlet weak var skeletonView: UIView!
    
    func configure(with movie: Movie?) {
        if let movie = movie {
            self.skeletonView.isHidden = true
            movieNameLabel?.text = movie.title
//            genreLabel?.text
            releaseDateLabel.text = movie.releaseDate
        } else {
            self.skeletonView.isHidden = false
        }
    }
}
