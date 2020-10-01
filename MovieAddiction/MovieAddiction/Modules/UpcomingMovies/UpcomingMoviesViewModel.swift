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
    var moviesViewModels: Driver<[MovieViewModel]> { get }
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
    var moviesViewModels: Driver<[MovieViewModel]> {
        Driver.merge(
            moviesRelay.asDriver(),
            searchText.map({ text in
                text.isEmpty ? self.viewModels : self.viewModels.filter { $0.title.lowercased().contains(text.lowercased()) }
            }).asDriver(onErrorJustReturn: [])
        )
    }

    private let provider: UpcomingMoviesProvider


    // MARK: Private subjects

    private let errorSubject: PublishSubject<Bool> = .init()
    private let loadingSubject: PublishSubject<Bool> = .init()
    var moviesRelay: BehaviorRelay<[MovieViewModel]> = .init(value: [])
    private let searchText: BehaviorRelay<String> = .init(value: "")

    private var viewModels: [MovieViewModel] = []

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
        observable.bind(to: searchText)
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
                self.total = response.totalResults
                let newMoviesViewModels = response.results.map { MovieViewModel(movie: $0) }
                self.viewModels.append(contentsOf: newMoviesViewModels)
                self.moviesRelay.accept(self.viewModels)
                break
            }
        }
    }
    
    func cancelSearch() {
        searchText.accept("")
    }
}
