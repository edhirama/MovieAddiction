//
//  AppDelegate.swift
//  MovieAddiction
//
//  Created by Edgar Hirama on 26/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewModel = UpcomingMoviesViewModel(provider: RemoteUpcomingMoviesProvider(networkService: HTTPService(endpoint: UpcomingMoviesEndpoint())))
        let viewController = UpcomingMoviesViewController.instantiate(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }


}

