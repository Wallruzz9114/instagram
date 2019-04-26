//
//  PhotoSelectorHeaderCollectionViewCell.swift
//  Instagram
//
//  Created by José Pinto on 4/7/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

class PhotoSelectorHeaderCollectionViewCell: UICollectionViewCell {

    // Image view for cell image
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        //imageView.backgroundColor = UIColor.cyan
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Add to the view and set constraints
        self.addSubview(photoImageView)
        photoImageView.setConstraintsWithAnchors(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
