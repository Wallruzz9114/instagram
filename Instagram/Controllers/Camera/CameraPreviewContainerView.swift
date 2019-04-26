//
//  CameraPreviewContainerView.swift
//  Instagram
//
//  Created by José Pinto on 4/24/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Photos

class CameraPreviewContainerView: UIView {

    let previewImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()

    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.yellow

        addAllSubviews()
        addAllConstraints()
    }

    func addAllSubviews() {
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
    }

    func addAllConstraints() {
        previewImageView.setConstraintsWithAnchors(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cancelButton.setConstraintsWithAnchors(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        saveButton.setConstraintsWithAnchors(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func handleCancel() {
        self.removeFromSuperview()
    }

    @objc fileprivate func handleSave() {
        guard let previewImage = previewImageView.image else { return }
        let library = PHPhotoLibrary.shared()

        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, error) in
            if let error = error {
                print("Failed to save image to library:", error.localizedDescription)
            } else {
                print("Successfully save image to library")

                DispatchQueue.main.async {
                    let savedLabel = UILabel()
                    savedLabel.text = "Saved Successfully!"
                    savedLabel.textColor = UIColor.white
                    savedLabel.font = UIFont.boldSystemFont(ofSize: 14)
                    savedLabel.textAlignment = .center
                    savedLabel.numberOfLines = 0
                    savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                    savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                    savedLabel.center = self.center
                    savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)

                    self.addSubview(savedLabel)

                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    }, completion: { (completed) in
                        UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                            savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                            savedLabel.alpha = 0
                        }, completion: { (_) in
                            savedLabel.removeFromSuperview()
                        })
                    })
                }
            }
        }
    }

}
