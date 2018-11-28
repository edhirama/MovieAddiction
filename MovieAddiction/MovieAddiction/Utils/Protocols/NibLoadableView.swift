//
//  NibLoadableView.swift
//  StartupRating
//
//  Created by Edgar Hirama on 22/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation
import UIKit

protocol NibLoadableView {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}
