//
//  CommentCollectionViewController.swift
//  Instagram
//
//  Created by José Pinto on 4/19/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class CommentCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var post: Post?
    var comments = [Comment]()
    let cellID = "cellID"

    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)

        containerView.addSubview(commentTextField)
        containerView.addSubview(submitCommentButton)
        containerView.addSubview(lineSeparatorView)

        commentTextField.setConstraintsWithAnchors(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitCommentButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        submitCommentButton.setConstraintsWithAnchors(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        lineSeparatorView.setConstraintsWithAnchors(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)

        return containerView
    }()

    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter comment..."
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.layer.cornerRadius = 5
        textField.autocapitalizationType = .none
        return textField
    }()

    let submitCommentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor.getInstagramBlue(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSubmitCommentButton), for: .touchUpInside)
        return button
    }()

    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#e6e6e6")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Comments"

        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: cellID)

        fetchComments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
    }

    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CommentCollectionViewCell
        cell.comment = self.comments[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCollectionViewCell(frame: frame)

        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()

        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)

        return CGSize(width: view.frame.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    fileprivate func fetchComments() {
        guard let postID = self.post?.postID else { return }
        let reference = Database.database().reference().child("comments").child(postID)

        reference.observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            // Access the commenter
            guard let poster_id = dictionary["op_id"] as? String else { return }

            Database.fetchUserWithUID(uid: poster_id, completion: { (poster) in
                let comment = Comment(user: poster, dictionary: dictionary)

                self.comments.append(comment)
                self.collectionView?.reloadData()

                self.comments.sort(by: { (firstComment, secondComment) -> Bool in
                    firstComment.createdAt.compare(secondComment.createdAt) == .orderedAscending
                })
            })
        }) { (error) in
            print("Faailed to observe comment:", error.localizedDescription)
        }
    }

    @objc fileprivate func handleSubmitCommentButton() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postID = self.post?.postID else { return }

        let values = ["op_id": uid, "text": self.commentTextField.text ?? "", "created_at": Date().timeIntervalSince1970] as [String : Any]

        Database.database().reference().child("comments").child(postID).childByAutoId().updateChildValues(values, withCompletionBlock: { (error, reference) in
            if let error = error {
                print("Failed to insert comment:", error.localizedDescription)
                return
            } else {
                print("Successfully inserted comment!")
            }
        })
    }

}
