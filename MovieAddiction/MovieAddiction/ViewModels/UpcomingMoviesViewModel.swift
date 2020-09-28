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
    private var moviesViewModels = [MovieViewModel]()
    private var filteredMoviesViewModels = [MovieViewModel]()
    
    private var isFiltering = false
    
    var totalCount: Int {
        return isFiltering ? filteredMoviesViewModels.count : total
    }
    
    var currentCount: Int {
        return isFiltering ? filteredMoviesViewModels.count : moviesViewModels.count
    }

    private let provider: UpcomingMoviesProvider

    // MARK: Constructor

    init(provider: UpcomingMoviesProvider) {
        self.provider = provider
    }

    // MARK: Table view
    
    func movieViewModel(at index: Int) -> MovieViewModel {
        return isFiltering ? filteredMoviesViewModels[index] : moviesViewModels[index]
    }

    // MARK: Network methods
    
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

        provider.retrieveList(page: currentPage) { [weak self] (result) in
            guard let self = self else { return }
            self.isFetchInProgress = false
            switch (result) {
            case .failure(let error):
                self.delegate?.onFetchFailed(with: error.localizedDescription)
                break
            case .success(let response):
                self.currentPage += 1
                if self.total == 0 {
                    self.total = response.totalResults
                }
                let newMoviesViewModels = response.results.map({ (movie) -> MovieViewModel in
                    return MovieViewModel(movie: movie)
                })
                self.moviesViewModels.append(contentsOf: newMoviesViewModels)

                if response.page > 1 {
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: newMoviesViewModels)
                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                } else {
                    self.delegate?.onFetchCompleted(with: .none)
                }
                break
            }
        }
    }
    
    //MARK: Search methods
    
    func filter(forSearchText searchText: String, scope: String = "All") {
        guard !searchText.isEmpty else { return }
        self.isFiltering = true

        filteredMoviesViewModels = moviesViewModels.filter({ movieVM -> Bool in
            return movieVM.title.lowercased().contains(searchText.lowercased())
        })
        
        self.delegate?.reloadData()
    }
    
    func cancelSearch() {
        self.isFiltering = false
        self.delegate?.reloadData()
    }
    
    //MARK:- Helper methods
    
    private func calculateIndexPathsToReload(from newMovies: [MovieViewModel]) -> [IndexPath] {
        let startIndex = moviesViewModels.count - newMovies.count
        let endIndex = startIndex + newMovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
