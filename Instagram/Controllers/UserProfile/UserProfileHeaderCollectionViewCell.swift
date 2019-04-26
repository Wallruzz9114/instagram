//
//  UserProfileHeaderCollectionViewCell.swift
//  Instagram
//
//  Created by José Pinto on 4/1/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeaderCollectionViewCell: UICollectionViewCell {

    var delegate: UserProfileHeaderCollectionViewCellDelegate?

    // Create user and set profile image
    var user: User? {
        didSet {
            guard let profileImageURL = user?.profileImageURL else { return }
            profileImageView.loadImage(urlString: profileImageURL)
            // Set username label
            usernameLabel.text = self.user?.username
            // Set up Edit/follow button
            setUpEditFollowButton()
        }
    }

    // Profile image view
    let profileImageView: CustomImageView = {
        let imageView: CustomImageView = CustomImageView()
        imageView.layer.cornerRadius = 85 / 2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.magenta.cgColor
        imageView.layer.borderWidth = 3
        return imageView
    }()

    // Grid button
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()

    // List button
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()

    // Bookmark button
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()

    // Top divider (line above the 3 buttons)
    let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()

    // Bottom divider (line below the 3 buttons)
    let bottomDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()

    // Username label
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    // Posts label
    let postsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // Followers label
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // Following label
    let followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // Edit profile button
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Add subview and set constraints for profile image view
        self.addSubview(profileImageView)
        self.addSubview(usernameLabel)
        self.addSubview(editProfileFollowButton)

        profileImageView.setConstraintsWithAnchors(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 85, height: 85)

        // Set up grid, list and bookmark buttons at the bottom of the header
        setUpBottomButtons()

        // Set up username label
        usernameLabel.setConstraintsWithAnchors(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: gridButton.topAnchor, right: self.rightAnchor, paddingTop: -12, paddingLeft: 28, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)

        // Set up grid for user stats in the header
        setUpUsersStats()

        // Set up edit profile button
        editProfileFollowButton.setConstraintsWithAnchors(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setUpBottomButtons() {
        // Create an array of buttons (grid button, list button and bookmark button)
        let buttonsStackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually

        // Add it to the header view, along with the top and bottom dividers
        self.addSubview(buttonsStackView)
        self.addSubview(topDividerView)
        self.addSubview(bottomDividerView)

        // Set constraints
        buttonsStackView.setConstraintsWithAnchors(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        topDividerView.setConstraintsWithAnchors(top: buttonsStackView.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.setConstraintsWithAnchors(top: buttonsStackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }

    @objc fileprivate func handleEditProfileOrFollow() {
        guard let currentLoggedInUserID = Auth.auth().currentUser?.uid else { return }
        guard let userID = user?.uid else { return }

        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            // Unfollow
            Database.database().reference().child("following").child(currentLoggedInUserID).child(userID).removeValue { (error, reference) in
                if let error = error {
                    print("Failed to unfollow user:", error.localizedDescription)
                    return
                } else {
                    print("Successfully unfollowed user:", self.user?.username ?? "")
                }
                // Set button
                self.setUpFollowButtonStyle()
            }
        } else {
            // Follow
            let reference = Database.database().reference().child("following").child(currentLoggedInUserID)
            let values = [userID: 1]

            reference.updateChildValues(values) { (error, dataReference) in
                if let error = error {
                    print("Failed to follow user:", error.localizedDescription)
                    return
                } else {
                    print("Successfully follwed user:", self.user?.username ?? "")
                }
                // Style button
                self.setUpUnfollowButtonStyle()
            }
        }
    }

    fileprivate func setUpFollowButtonStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.getInstagramBlue()
        self.editProfileFollowButton.setTitleColor(UIColor.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }

    fileprivate func setUpUnfollowButtonStyle() {
        self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.white
        self.editProfileFollowButton.setTitleColor(UIColor.black, for: .normal)
    }

    fileprivate func setUpUsersStats() {
        // Create an array of buttons (labels)
        let labelsStackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        labelsStackView.axis = .horizontal
        labelsStackView.distribution = .fillEqually
        // Add it to the header
        self.addSubview(labelsStackView)
        // Set constraints
        labelsStackView.setConstraintsWithAnchors(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }

    @objc fileprivate func handleChangeToListView() {
        listButton.tintColor = UIColor.getInstagramBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)

        delegate?.onTapListButton()
    }

    @objc fileprivate func handleChangeToGridView() {
        gridButton.tintColor = UIColor.getInstagramBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)

        delegate?.onTapGridButton()
    }

    fileprivate func setUpEditFollowButton() {
        guard let currentLoggedInUserID = Auth.auth().currentUser?.uid else { return }
        guard let userID = user?.uid else { return }

        // If users are different, set title to "Follow". Else, keep title as 'Edit'
        if currentLoggedInUserID != userID {
            // Check if following for button style
            Database.database().reference().child("following").child(currentLoggedInUserID).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setUpFollowButtonStyle()
                }
            }) { (error) in
                print("Failed to check if following:", error.localizedDescription)
            }
        }
    }

}
