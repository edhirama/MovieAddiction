//
//  ImageUtils.swift
//  StartupRating
//
//  Created by Edgar Hirama on 22/11/18.
//  Copyright © 2018 Edgar. All rights reserved.
//

import Foundation
import UIKit

class ImageHelper {
    
    static func load(url: URL, completion: @escaping (_ image: UIImage) -> Void)  {
        DispatchQueue.global().async { 
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }
    }

    
}
