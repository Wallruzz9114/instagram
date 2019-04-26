//
//  CommentCollectionViewCell.swift
//  Instagram
//
//  Created by José Pinto on 4/20/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {

    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])

            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            commentTextView.attributedText = attributedText
            commentProfileImageView.loadImage(urlString: comment.user.profileImageURL)
        }
    }

    let commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        return textView
    }()

    let commentProfileImageView: CustomImageView = {
        let imageView: CustomImageView = CustomImageView()
        imageView.layer.cornerRadius = 40 / 2
        imageView.backgroundColor = UIColor.green
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addAllSubviews()
        addAllConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func addAllSubviews() {
        addSubview(commentTextView)
        addSubview(commentProfileImageView)
    }

    fileprivate func addAllConstraints() {
        commentTextView.setConstraintsWithAnchors(top: topAnchor, left: commentProfileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        commentProfileImageView.setConstraintsWithAnchors(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
    }
    
}
