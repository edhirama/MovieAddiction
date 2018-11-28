//
//  Reusable.swift
//  StartupRating
//
//  Created by Edgar Hirama on 22/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable {
    static var reusableIdentifier: String { get }
}

extension Reusable where Self: UIView {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}
