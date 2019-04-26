//
//  HomeCollectionViewController.swift
//  Instagram
//
//  Created by José Pinto on 4/13/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class HomePostCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCollectionViewCellDelegate {

    let cellID: String = "cellID"
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateHomeFeed), name: SharePhotoViewController.updateFeedNotificationName, object: nil)

        collectionView?.backgroundColor = UIColor.white
        // Register cells for post image list
        collectionView?.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: cellID)

        // Set spinner on top for refreshing
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl

        // Set navigation items
        setUpNavigationItems()
        // Set images
        fetchAllPosts()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8 // username and userprofile image view
        height += view.frame.width
        height += 50 // for action buttons
        height += 40 // for caption and timestamp
        return CGSize(width: view.frame.width, height: height)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomePostCollectionViewCell

        cell.post = posts[indexPath.item]
        cell.delegate = self

        return cell
    }

    fileprivate func setUpNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }

    func fetchOrderedImagesForHomeFeed() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsFor(user: user)
        }
    }

    @objc fileprivate func handleCamera() {
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true, completion: nil)
    }

    fileprivate func fetchPostsFor(user: User) {
        let reference = Database.database().reference().child("posts").child(user.uid)

        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView?.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String: Any] else { return }

            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.postID = key

                Database.database().reference().child("likes").child(key).child("follower").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let uid = Auth.auth().currentUser?.uid else { return }

                    if let value = snapshot.value as? String, value == uid {
                        post.hasBeenLiked = true
                    } else {
                        post.hasBeenLiked = false
                    }

                    self.posts.append(post)
                    self.posts.sort(by: { (firstPost, secondPost) -> Bool in
                        firstPost.createdAt.compare(secondPost.createdAt) == .orderedDescending
                    })

                    self.collectionView?.reloadData()
                }, withCancel: { (error) in
                    print("Failed to fetch like info for post:", error.localizedDescription)
                })
            })
        }) { (error) in
            print("Failed to fetch posts:", error.localizedDescription)
        }
    }

    fileprivate func fetchPostsForUsersFollowed() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIDsDictionary = snapshot.value as? [String: Any] else { return }

            userIDsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsFor(user: user)
                })
            })
        }) { (error) in
            print("Failed to fetch posts for users followed:", error.localizedDescription)
        }
    }

    @objc fileprivate func handleUpdateHomeFeed() {
        handleRefresh()
    }

    @objc fileprivate func handleRefresh() {
        self.posts.removeAll()
        fetchAllPosts()
    }

    fileprivate func fetchAllPosts() {
        fetchOrderedImagesForHomeFeed()
        fetchPostsForUsersFollowed()
    }

    func onTapCommentButton(post: Post) {
        let commentCollectionViewController = CommentCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        commentCollectionViewController.post = post
        navigationController?.pushViewController(commentCollectionViewController, animated: true)
    }

    func onTapLikeButton(for cell: HomePostCollectionViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        guard let postID = post.postID else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["follower": post.hasBeenLiked == true ? "none" : uid]

        Database.database().reference().child("likes").child(postID).updateChildValues(values) { (error, _) in
            if let error = error {
                print("Failed to like post:", error.localizedDescription)
                return
            } else {
                print("Sucessfully liked post")
                post.hasBeenLiked = !post.hasBeenLiked
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
    }

}
