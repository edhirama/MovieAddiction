//
//  ViewController.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 26/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class UpcomingMoviesViewController: UIViewController {

    let showMovieDetailsSegueIdentifier = "showMovieDetail"
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var retryButton: UIButton!
    private let imageCache = NSCache<NSString, UIImage>()
    private var viewModel: UpcomingMoviesViewModelType?
    private let disposeBag: DisposeBag = .init()
    private let searchController = UISearchController(searchResultsController: nil)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: Lifecycle

    static func instantiate(viewModel: UpcomingMoviesViewModelType) -> UpcomingMoviesViewController {
        guard let viewController = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(identifier: "UpcomingMoviesViewController") as? UpcomingMoviesViewController else {
            fatalError("Should be able to to instantiate UpcomingMoviesViewController")
        }
        viewController.viewModel = viewModel
        return viewController
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func loadView() {
        super.loadView()
        LoadingIndicator.shared.show()
        viewModel?.fetchData()
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavigationBar()
        setupTableView()
        setupViewModelBinds()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showMovieDetailsSegueIdentifier {
            if let destinationViewController = segue.destination as? MovieDetailViewController, let viewModel = sender as? MovieViewModel {
                destinationViewController.viewModel = viewModel
            }
        }
    }
    
    //MARK: View Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.barStyle = .black
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.register(UpcomingMoviesTableViewCell.self)
        setupTableViewBinds()
    }

    private func setupTableViewBinds() {
        tableView.rx.modelSelected(MovieViewModel.self).bind { [weak self] movie in
            if let movieDetails = self?.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
                movieDetails.viewModel = movie
                self?.present(movieDetails, animated: true, completion: nil)
            }
        }.disposed(by: disposeBag)
        tableView.rx.didScroll.bind{ [weak searchController] in
            searchController?.searchBar.resignFirstResponder()
        }.disposed(by: disposeBag)
    }

    // MARK: Setup binds

    private func setupViewModelBinds() {

        viewModel?.moviesViewModels.drive(
            tableView.rx.items(
                cellIdentifier: UpcomingMoviesTableViewCell.reusableIdentifier)) { _, movie, cell in
                    guard let cell = cell as? UpcomingMoviesTableViewCell else { return }
            cell.configure(with: movie)
            if let cachedImage = self.imageCache.object(forKey: NSString(string: movie.imageURL)) {
                cell.posterImageView.image = cachedImage
            } else {
                self.loadImage(cell: cell, movie: movie)
            }
        }.disposed(by: disposeBag)

        viewModel?.shouldHideError.drive(errorView.rx.isHidden).disposed(by: disposeBag)

        viewModel?.shouldHideLoading.drive(onNext: { hideLoading in
            hideLoading ? LoadingIndicator.shared.hide() : LoadingIndicator.shared.show()
        }).disposed(by: disposeBag)

        viewModel?.bindRetry(retryButton.rx.tap.asObservable()).disposed(by: disposeBag)
        viewModel?.bindCancellingSearch(searchController.rx.didDismiss).disposed(by: disposeBag)
        viewModel?.bindSearchText(searchController.searchBar.rx.text.compactMap { $0 }.asObservable()).disposed(by: disposeBag)
    }
    // MARK: Actions
    
    @IBAction func retryButtonClicked(_ sender: Any) {
        self.viewModel?.fetchData()
    }

    private func loadImage(cell: UpcomingMoviesTableViewCell, movie: MovieViewModel) {
        if let url = URL(string: movie.imageURL) {
            ImageHelper.load(url: url) { [weak self] (image) in
                self?.imageCache.setObject(image, forKey: NSString(string: movie.title))
                cell.posterImageView.image = image
            }
        }
    }
}
