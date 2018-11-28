//
//  UITableView+custom.swift
//  StartupRating
//
//  Created by Edgar Hirama on 22/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(_ : T.Type) where T:Reusable, T:NibLoadableView  {
        self.register(T.nib, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(_ : T.Type) where T:Reusable, T:NibLoadableView  {
        self.register(T.nib, forHeaderFooterViewReuseIdentifier: T.reusableIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ indexPath: IndexPath) -> T where T: Reusable, T:NibLoadableView {
        
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reusableIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue the cell \(T.reusableIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T where T:Reusable, T:NibLoadableView {
        guard let headerFooter = self.dequeueReusableHeaderFooterView(withIdentifier: T.reusableIdentifier) as? T else {
            
            fatalError("Could not dequeue the header/footer view \(T.reusableIdentifier)")
        }
        return headerFooter
    }
    
}
