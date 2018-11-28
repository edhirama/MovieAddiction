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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    func configure(with movie: MovieViewModel?) {
        if let movie = movie {
            self.activityIndicator.stopAnimating()
            self.skeletonView.isHidden = true
            self.movieNameLabel?.text = movie.title
            self.releaseDateLabel.text = movie.releaseDate
            self.genreLabel.text = movie.genre
        } else {
            self.activityIndicator.stopAnimating()
            self.skeletonView.isHidden = true
            self.movieNameLabel?.text = ""
            self.releaseDateLabel.text = ""
            self.genreLabel.text = ""
            self.skeletonView.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
}
