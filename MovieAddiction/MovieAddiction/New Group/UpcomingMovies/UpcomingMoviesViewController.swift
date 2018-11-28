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
    
    let viewModel = UpcomingMoviesViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
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
            cell.configure(with: viewModel.movie(at: indexPath.row))
        }
        return cell
    }

}

extension UpcomingMoviesViewController: UpcomingMoviesViewModelDelegate {
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        
        guard let newIndexPathsToReload = newIndexPathsToReload else {
//            indicatorView.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        //TODO handle error
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
