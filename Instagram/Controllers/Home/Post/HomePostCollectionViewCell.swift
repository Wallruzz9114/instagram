//
//  HomePostCollectionViewCell.swift
//  Instagram
//
//  Created by José Pinto on 4/13/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

class HomePostCollectionViewCell: UICollectionViewCell {

    var delegate: HomePostCollectionViewCellDelegate?

    var post: Post? {
        didSet {
            guard let homePostImageURL = post?.imageURL else { return }
            likeButton.setImage(post?.hasBeenLiked == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            homePostImageView.loadImage(urlString: homePostImageURL)
            usernameLabel.text = post?.user.username
            // Set profile picture on the home feed
            guard let profileImageURL = post?.user.profileImageURL else { return }
            userProfileImageView.loadImage(urlString: profileImageURL)
            // Set caption text
            setUpCaption()
        }
    }

    let userProfileImageView: CustomImageView = {
        let imageView: CustomImageView = CustomImageView()
        imageView.layer.cornerRadius = 40 / 2
        imageView.clipsToBounds = true
        return imageView
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()

    let homePostImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()

    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addAllSubviews()
        setUpAllConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func addAllSubviews() {
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(homePostImageView)
        addSubview(captionLabel)
    }

    fileprivate func setUpAllConstraints() {
        userProfileImageView.setConstraintsWithAnchors(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        usernameLabel.setConstraintsWithAnchors(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: homePostImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        optionsButton.setConstraintsWithAnchors(top: topAnchor, left: nil, bottom: homePostImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        homePostImageView.setConstraintsWithAnchors(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homePostImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        setUpActionButtons()

        captionLabel.setConstraintsWithAnchors(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }

    fileprivate func setUpActionButtons() {
        let actionButtonsStackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendButton])

        actionButtonsStackView.distribution = .fillEqually
        addSubview(actionButtonsStackView)
        addSubview(bookmarkButton)

        actionButtonsStackView.setConstraintsWithAnchors(top: homePostImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        bookmarkButton.setConstraintsWithAnchors(top: homePostImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
    }

    fileprivate func setUpCaption() {
        // Get post data from Firebase
        guard  let post = self.post else { return }

        let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(string: post.user.username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
        let timeAgoDisplay = post.createdAt.timeAgoPrettyDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.gray]))

        self.captionLabel.attributedText = attributedText
    }

    @objc fileprivate func handleComment() {
        guard let post = self.post else { return }
        delegate?.onTapCommentButton(post: post)
    }

    @objc fileprivate func handleLike() {
        delegate?.onTapLikeButton(for: self)
    }

}
