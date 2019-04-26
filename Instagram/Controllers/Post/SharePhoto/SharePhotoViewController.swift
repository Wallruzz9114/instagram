//
//  SharePhotoController.swift
//  Instagram
//
//  Created by José Pinto on 4/12/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoViewController: UIViewController {

    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")

    let postContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let captionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor(hexString: "#95ccf4").cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        textView.placeholder = "Insert your caption here!"
        textView.autocapitalizationType = .none
        return textView
    }()

    var selectedImage: UIImage? {
        didSet {
            self.selectedImageView.image = selectedImage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexString: "#f0f0f0")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(handleShare))

        setUpImageAndTextViews()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    fileprivate func setUpImageAndTextViews() {
        view.addSubview(postContainerView)
        postContainerView.setConstraintsWithAnchors(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        view.addSubview(selectedImageView)
        selectedImageView.setConstraintsWithAnchors(top: postContainerView.topAnchor, left: postContainerView.leftAnchor, bottom: postContainerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        view.addSubview(captionTextView)
        captionTextView.setConstraintsWithAnchors(top: postContainerView.topAnchor, left: selectedImageView.rightAnchor, bottom: postContainerView.bottomAnchor, right: postContainerView.rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
    }

    @objc fileprivate func handleShare() {
        // Get image out of image view
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }

        navigationItem.rightBarButtonItem?.isEnabled = false

        // Upload/Store to Firebase
        let fileName = NSUUID().uuidString

        Storage.storage().reference().child("posts").child(fileName).putData(uploadData, metadata: nil) { (metadata, error) in
            guard let caption = self.captionTextView.text, caption.count > 0 else { return }

            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("failed to upload image:", error.localizedDescription)
            } else {
                guard let imageURL = metadata?.downloadURL()?.absoluteString else { return }
                print("Successfully uploaded image at url:", imageURL)

                // Put it into the realtime database
                self.savePostToFirebaseDatabase(imageURL: imageURL, caption: caption)
            }
        }
    }

    fileprivate func savePostToFirebaseDatabase(imageURL: String, caption: String) {
        guard let postImage = selectedImage else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userPostReference = Database.database().reference().child("posts").child(uid)
        let reference = userPostReference.childByAutoId()
        let postValues = ["imageURL": imageURL, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "created_at": Date().timeIntervalSince1970] as [String : Any]

        reference.updateChildValues(postValues) { (error, reference) in
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("failed to save post to Firebase:", error.localizedDescription)
            } else {
                print("Successfully saved post in Firebase!")
                self.dismiss(animated: true, completion: nil)

                NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
            }
        }
    }

}
