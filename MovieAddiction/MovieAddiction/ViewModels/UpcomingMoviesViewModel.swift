//
//  UpcomingMoviesViewModel.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation

protocol UpcomingMoviesViewModelDelegate : class {
    func reloadData()
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

class UpcomingMoviesViewModel {
    
    weak var delegate: UpcomingMoviesViewModelDelegate?
    private var isFetchInProgress = false
    private var total = 0
    private var currentPage: Int = 1
    private var movies = [Movie]()
    private var moviesViewModels = [MovieViewModel]()
    private var filteredMovies = [Movie]()
    private var filteredMoviesViewModels = [MovieViewModel]()
    
    private var isFiltering = false
    
    var totalCount: Int {
        return isFiltering ? filteredMovies.count : total
    }
    
    var currentCount: Int {
        return isFiltering ? filteredMovies.count : movies.count
    }
    
    func movie(at index: Int) -> Movie {
        return isFiltering ? filteredMovies[index] : movies[index]
    }
    
    func movieViewModel(at index: Int) -> MovieViewModel {
        return isFiltering ? filteredMoviesViewModels[index] : moviesViewModels[index]
    }
    
    //MARK: Network methods
    
    func fetchData() {
        if GenresHelper.shared.genres.count == 0 {
            let requestQueue = OperationQueue()
            
            let requestOperation = BlockOperation {
                let group = DispatchGroup()
                
                group.enter()
                GenresHelper.shared.retrieveGenres {
                    group.leave()
                }
                
                group.wait()
                
                self.fetchMovies()
                
            }
            
            requestQueue.addOperation(requestOperation)
            
        } else {
            fetchMovies()
        }
    }
    
    func fetchMovies() {
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        UpcomingMoviesService.retrieveList(page: currentPage) { [weak self] (result) in
            switch (result) {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                    self?.delegate?.onFetchFailed(with: error.localizedDescription)
                }
                print(error)
                break
            case .success(let response):
                self?.currentPage += 1
                if let total = self?.total, total == 0 {
                    self?.total = response.totalResults
                }
                self?.movies.append(contentsOf: response.results)
                self?.moviesViewModels.append(contentsOf:  response.results.map({ (movie) -> MovieViewModel in
                    return MovieViewModel(movie: movie)
                }))
                self?.isFetchInProgress = false
                
                if response.page > 1 {
                    let indexPathsToReload = self?.calculateIndexPathsToReload(from: response.results)
                    self?.delegate?.onFetchCompleted(with: indexPathsToReload)
                } else {
                    self?.delegate?.onFetchCompleted(with: .none)
                }
                break
            }
        }
    }
    
    //MARK: Search methods
    
    func filter(forSearchText searchText: String, scope: String = "All") {
        
        self.isFiltering = true
        
        filteredMovies = movies.filter({( movie : Movie) -> Bool in
            return movie.title.lowercased().contains(searchText.lowercased())
        })
        
        filteredMoviesViewModels = filteredMovies.map({ (movie) -> MovieViewModel in
            return MovieViewModel(movie: movie)
        })
        
        self.delegate?.reloadData()
    }
    
    func cancelSearch() {
        self.isFiltering = false
        self.delegate?.reloadData()
    }
    
    //MARK:- Helper methods
    
    private func calculateIndexPathsToReload(from newMovies: [Movie]) -> [IndexPath] {
        let startIndex = movies.count - newMovies.count
        let endIndex = startIndex + newMovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
