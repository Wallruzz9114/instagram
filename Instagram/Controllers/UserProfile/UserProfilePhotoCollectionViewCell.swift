//
//  UserProfilePhotoCollectionViewCell.swift
//  Instagram
//
//  Created by José Pinto on 4/12/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

class UserProfilePhotoCollectionViewCell: UICollectionViewCell {

    var post: Post? {
        didSet {
            guard let imageURL = post?.imageURL else { return }
            photoImageView.loadImage(urlString: imageURL)
        }
    }

    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(photoImageView)
        photoImageView.setConstraintsWithAnchors(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
