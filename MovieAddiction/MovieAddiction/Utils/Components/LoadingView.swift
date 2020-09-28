//
//  LoadingView.swift
//  StartUpRating
//
//  Created by Edgar Hirama on 26/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation
import UIKit

class LoadingIndicator: UIView {
    
    let loader = UIActivityIndicatorView()
    
    static let shared: LoadingIndicator = {
        let instance = LoadingIndicator()
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.frame = (UIApplication.shared.windows.first?.frame)!
        
        loader.frame = (UIApplication.shared.windows.first?.frame)!
        loader.style = .large
        loader.center = self.center
        loader.color = UIColor.darkGray
        self.addSubview(loader)
        
    }
    
    func show() {
        if let application = UIApplication.shared.delegate as? AppDelegate {
            
            application.window?.addSubview(self)
            
            loader.startAnimating()
            
            loader.bringSubviewToFront((application.window?.rootViewController?.view)!)
        }
    }
    
    func hide() {
        self.removeFromSuperview()
        loader.stopAnimating()
    }
    
}
