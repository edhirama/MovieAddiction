//
//  UpcomingMoviesViewModel.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 27/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import RxCocoa
import RxSwift

protocol UpcomingMoviesViewModelType {
    var moviesViewModels: PublishRelay<[MovieViewModel]> { get }
    var shouldHideError: Driver<Bool> { get }
    var shouldHideLoading: Driver<Bool> { get }

    func fetchData()
    func bindRetry(_ observable: Observable<Void>) -> Disposable
    func bindSearchText(_ observable: Observable<String>) -> Disposable
    func bindCancellingSearch(_ observable: Observable<Void>) -> Disposable
}

final class UpcomingMoviesViewModel: UpcomingMoviesViewModelType {
    var shouldHideLoading: Driver<Bool> {
        errorSubject.map { !$0 }.asDriver(onErrorJustReturn: false)
    }

    var shouldHideError: Driver<Bool> {
        loadingSubject.map { !$0 }.asDriver(onErrorJustReturn: false)
    }

    private var isFetchInProgress = false
    private var total = 0
    private var currentPage: Int = 1
    var moviesViewModels: PublishRelay<[MovieViewModel]> = .init()
    private var filteredMoviesViewModels = [MovieViewModel]()
    
    private var isFiltering = false
    private let provider: UpcomingMoviesProvider


    // MARK: Private subjects

    private let errorSubject: PublishSubject<Bool> = .init()
    private let loadingSubject: PublishSubject<Bool> = .init()
    private let moviesSubject: PublishSubject<[MovieViewModel]> = .init()

    // MARK: Constructor

    init(provider: UpcomingMoviesProvider) {
        self.provider = provider
    }


    // MARK: Binds


    func bindRetry(_ observable: Observable<Void>) -> Disposable {
        observable.subscribe(onNext: { [weak self] in
            self?.fetchData()
        })
    }

    func bindSearchText(_ observable: Observable<String>) -> Disposable {
        observable.subscribe(onNext: { [weak self] searchText in
            self?.filter(forSearchText: searchText)
        })
    }

    func bindCancellingSearch(_ observable: Observable<Void>) -> Disposable {
        observable.subscribe(onNext: { [weak self] in
            self?.cancelSearch()
        })
    }

    // MARK: Network methods
    
    func fetchData() {
        loadingSubject.onNext(true)
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

            self.loadingSubject.onNext(false)
            switch (result) {
            case .failure:
                self.errorSubject.onNext(true)
                break
            case .success(let response):
                self.errorSubject.onNext(false)
                self.currentPage += 1
                if self.total == 0 {
                    self.total = response.totalResults
                }
                let newMoviesViewModels = response.results.map({ (movie) -> MovieViewModel in
                    return MovieViewModel(movie: movie)
                })
                self.moviesViewModels.accept(newMoviesViewModels)

//                self.moviesViewModels.append(contentsOf: newMoviesViewModels)

                if response.page > 1 {
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: newMoviesViewModels)
//                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                } else {
//                    self.delegate?.onFetchCompleted(with: .none)
                }
                break
            }
        }
    }
    
    //MARK: Search methods
    
    func filter(forSearchText searchText: String, scope: String = "All") {
        guard !searchText.isEmpty else { return }
        self.isFiltering = true

//        filteredMoviesViewModels = moviesViewModels.filter({ movieVM -> Bool in
//            return movieVM.title.lowercased().contains(searchText.lowercased())
//        })
        
//        self.delegate?.reloadData()
    }
    
    func cancelSearch() {
        self.isFiltering = false
//        self.delegate?.reloadData()
    }
    
    //MARK:- Helper methods
    
    private func calculateIndexPathsToReload(from newMovies: [MovieViewModel]) -> [IndexPath] {
//        let startIndex = moviesViewModels.count - newMovies.count
//        let endIndex = startIndex + newMovies.count
//        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        return []
    }
}