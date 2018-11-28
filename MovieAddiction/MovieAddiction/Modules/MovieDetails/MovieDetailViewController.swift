//
//  MovieDetailViewController.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 28/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterImageVIew: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var viewModel: MovieViewModel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    
    }
    
    func configureView(){
        self.genreLabel.text = viewModel.genre
        self.movieTitleLabel.text = viewModel.title
        self.releaseDateLabel.text = viewModel.releaseDate
        self.overviewLabel.text = viewModel.overview
        

        if let url = URL(string: "https://image.tmdb.org/t/p/w600_and_h900_bestv2\(self.viewModel.imageURL)") {
            
            ImageHelper.load(url: url, completion: { (image) in
                self.posterImageVIew.image = image
            })
            
        }
        
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
