//
//  SearchCollectionViewCell.swift
//  Instagram
//
//  Created by José Pinto on 4/17/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {

    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            guard let profileImageURL = user?.profileImageURL else { return }
            profileImageView.loadImage(urlString: profileImageURL)
        }
    }

    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.backgroundColor = UIColor.red
        imageView.layer.cornerRadius = 50 / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Add Subviews
        addAllSubviews()
        // set up constraints
        setUpAllConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func addAllSubviews() {
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(separatorView)
    }

    fileprivate func setUpAllConstraints() {
        setUpProfileImageView()
        // Set up username label
        usernameLabel.setConstraintsWithAnchors(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        // Set up separator view
        separatorView.setConstraintsWithAnchors(top: nil, left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }

    fileprivate func setUpProfileImageView() {
        profileImageView.setConstraintsWithAnchors(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }


}
