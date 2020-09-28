//
//  ViewController.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 26/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import UIKit

class UpcomingMoviesViewController: UIViewController {

    let showMovieDetailsSegueIdentifier = "showMovieDetail"
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let imageCache = NSCache<NSString, UIImage>()
    let viewModel = UpcomingMoviesViewModel(provider: RemoteUpcomingMoviesProvider(networkService: HTTPService(endpoint: UpcomingMoviesEndpoint())))
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        LoadingIndicator.shared.show()
        viewModel.fetchData()
        self.setupTableView()
        
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    //MARK: View Setup
    
    func setupNavigationBar() {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        } else {
            // keep the navigation bar as it is
        }
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        definesPresentationContext = true
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.prefetchDataSource = self
        self.tableView.register(UpcomingMoviesTableViewCell.self)
    }
    
    // MARK: Actions
    
    @IBAction func retryButtonClicked(_ sender: Any) {
        LoadingIndicator.shared.show()
        self.errorView.isHidden = true
        self.viewModel.fetchData()
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
            if let cachedImage = self.imageCache.object(forKey: NSString(string: viewModel.movie(at: indexPath.row).title)) {
                cell.posterImageView.image = cachedImage
            } else {
                cell.posterImageView.image = nil
                loadImage(cell: cell, indexPath: indexPath)
            }
          
        }
        return cell
    }
    
    func loadImage(cell: UpcomingMoviesTableViewCell, indexPath: IndexPath) {
        let movie = self.viewModel.movieViewModel(at: indexPath.row)
        if let url = URL(string: movie.imageURL) {
            ImageHelper.load(url: url) { [weak self] (image) in
                if let updatedCell = self?.tableView.cellForRow(at: indexPath) as? UpcomingMoviesTableViewCell {
                    self?.imageCache.setObject(image, forKey: NSString(string: movie.title))
                    updatedCell.posterImageView.image = image
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < self.viewModel.currentCount {
            if let movieDetails = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
                movieDetails.viewModel = self.viewModel.movieViewModel(at: indexPath.row)
                present(movieDetails, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showMovieDetailsSegueIdentifier {
            if let destinationViewController = segue.destination as? MovieDetailViewController, let viewModel = sender as? MovieViewModel {
                destinationViewController.viewModel = viewModel
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController.searchBar.resignFirstResponder()
    }
}

extension UpcomingMoviesViewController: UpcomingMoviesViewModelDelegate {
    
    func reloadData() {
        self.errorView.isHidden = true
        tableView.reloadData()
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        
        self.errorView.isHidden = true
        LoadingIndicator.shared.hide()
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: indexPathsToReload, with: .none)
        }
    }
    
    func onFetchFailed(with reason: String) {
        LoadingIndicator.shared.hide()
        self.errorView.isHidden = false
        print(reason)
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


extension UpcomingMoviesViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel.filter(forSearchText: searchController.searchBar.text!)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {   
        self.viewModel.cancelSearch()
    }
}
