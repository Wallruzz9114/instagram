//
//  UIImageViewRendering.swift
//  Instagram
//
//  Created by José Pinto on 4/12/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {

    var lastURLUsedtoLoadImage: String?

    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        lastURLUsedtoLoadImage = urlString

        self.image = nil

        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to fetch post image:", error.localizedDescription)
                return
            } else if url.absoluteString != self.lastURLUsedtoLoadImage {
                return
            } else {
                guard let imageData = data else { return }
                let photoImage = UIImage(data: imageData)
                imageCache[url.absoluteString] = photoImage

                DispatchQueue.main.async {
                    self.image = photoImage
                }
            }
        }.resume()
    }

}
