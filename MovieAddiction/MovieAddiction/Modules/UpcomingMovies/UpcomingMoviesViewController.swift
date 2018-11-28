//
//  ViewController.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 26/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import UIKit

class UpcomingMoviesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let imageCache = NSCache<NSString, UIImage>()
    let viewModel = UpcomingMoviesViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        LoadingIndicator.shared.show()
        viewModel.fetchMovies()
        self.setupTableView()
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.prefetchDataSource = self
        self.tableView.register(UpcomingMoviesTableViewCell.self)
    }
}

extension UpcomingMoviesViewController: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath) as UpcomingMoviesTableViewCell
        
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        } else {
            cell.configure(with: viewModel.movieViewModel(at: indexPath.row))
            if let cachedImage = self.imageCache.object(forKey: NSString(string: viewModel.movie(at: indexPath.row).originalTitle)) {
                cell.posterImageView.image = cachedImage
            } else {
                loadImage(cell: cell, indexPath: indexPath)
            }
          
        }
        return cell
    }
    
    func loadImage(cell: UpcomingMoviesTableViewCell, indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async {
            let movie = self.viewModel.movie(at: indexPath.row)
            let imageURL = movie.posterPath != nil ? movie.posterPath! : (movie.backdropPath ?? "")
            if let url = URL(string: "https://image.tmdb.org/t/p/w600_and_h900_bestv2\(imageURL)") {
                if let data = try? Data(contentsOf: url) {
                    let image: UIImage = UIImage(data: data)!
                    DispatchQueue.main.async {
                        if let updatedCell = self.tableView.cellForRow(at: indexPath) as? UpcomingMoviesTableViewCell {
                            self.imageCache.setObject(image, forKey: NSString(string: movie.originalTitle))
                            updatedCell.posterImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showMovieDetail", sender: self.viewModel.movieViewModel(at: indexPath.row))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetail" {
            if let destinationViewController = segue.destination as? MovieDetailViewController, let viewModel = sender as? MovieViewModel {
                destinationViewController.viewModel = viewModel
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UpcomingMoviesViewController: UpcomingMoviesViewModelDelegate {
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.isHidden = false
            tableView.reloadData()
            LoadingIndicator.shared.hide()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
    
    func onFetchFailed(with reason: String) {
        //TODO handle error
        print(reason)
        LoadingIndicator.shared.hide()
    }
}


extension UpcomingMoviesViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.fetchMovies()
        }
    }
}

private extension UpcomingMoviesViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currentCount
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
