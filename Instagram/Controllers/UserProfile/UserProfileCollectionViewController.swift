//
//  UserProfileViewController.swift
//  Instagram
//
//  Created by José Pinto on 3/30/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class UserProfileCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderCollectionViewCellDelegate {

    var user: User?
    var posts = [Post]()
    var isGridView = true
    var userID: String?
    let cellID = "cellID"
    let headerID = "headerID"
    let  homePostCellID = "homePostCellID"
    var isFinishedPaging = false

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
        // Get user data
        fetchUser()
        // Register collection view with header
        collectionView?.register(UserProfileHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        collectionView?.register(UserProfilePhotoCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: homePostCellID)

        // Set up logout button (gear icon)
        setUpLogoutButton()

        // Render images on the profile page
        //fetchOrderedImagesForUserProfile()
    }

    // Set up a header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! UserProfileHeaderCollectionViewCell
        header.user = self.user
        header.delegate = self

        return header
    }

    // Set up header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }

    // Number of cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // pagination call
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            print("paginating posts.")
            paginatePosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserProfilePhotoCollectionViewCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellID, for: indexPath) as! HomePostCollectionViewCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }

    // Only 1 px between photos
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // get a 3x3 grid
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width / 3) - 2
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 // username and userprofile image view
            height += view.frame.width
            height += 50 // for action buttons
            height += 40 // for caption and timestamp
            return CGSize(width: view.frame.width, height: height)
        }
    }

    fileprivate func fetchUser() {
        let uid = self.userID ?? Auth.auth().currentUser?.uid ?? ""

        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()

            self.paginatePosts()
        }
    }

    fileprivate func paginatePosts() {
        guard let uid = self.user?.uid else { return }
        let reference = Database.database().reference().child("posts").child(uid)
        var query = reference.queryOrdered(byChild: "created_at")

        if posts.count > 0 {
            let value = posts.last?.createdAt.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }

        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            guard let user = self.user else { return }

            allObjects.reverse()

            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }

            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }

            allObjects.forEach({ (snapshot) in
                guard let dictionary =  snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)

                post.postID = snapshot.key
                self.posts.append(post)
            })

            self.posts.forEach({ (post) in
                print(post.postID ?? "")
            })

            self.collectionView?.reloadData()
        }) { (error) in
            print("Failed to fetch posts:", error.localizedDescription)
        }
    }

    fileprivate func setUpLogoutButton() {
        // Create button on the right side of nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
    }

    @objc func handleLogout() {
        // display alert controller with logout option
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                // sign out
                try Auth.auth().signOut()
                // Present Sign in controller
                let signInViewController = SignInViewController()
                let navigationController = UINavigationController(rootViewController: signInViewController)
                self.present(navigationController, animated: true, completion: nil)
            } catch let error {
                print("Error: failed to sign out:", error.localizedDescription)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func onTapGridButton() {
        isGridView = true
        collectionView?.reloadData()
    }

    func onTapListButton() {
        isGridView = false
        collectionView?.reloadData()
    }


    func fetchOrderedImagesForUserProfile() {
        guard let uid = self.user?.uid else { return }

        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchOrderedImagesFor(user: user)
        }
    }

    fileprivate func fetchOrderedImagesFor(user: User) {
        // Post data
        let reference = Database.database().reference().child("posts").child(user.uid)
        reference.queryOrdered(byChild: "created_at").observe(.childAdded, with: { (snapshot) in
            // Get the dictionary
            guard let dictionary = snapshot.value as? [String: Any] else { return }

            let post = Post(user: user, dictionary: dictionary)
            // Append post to post array
            self.posts.insert(post, at: 0)
            self.collectionView?.reloadData()
        }) { (error) in
            print("Failed to fetch ordered images:", error.localizedDescription)
        }
    }

}
