//
//  CameraViewController.swift
//  Instagram
//
//  Created by José Pinto on 4/19/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {

    let output = AVCapturePhotoOutput()
    let customAnimationPresentorViewControllerAnimatedTransitioning = CustomAnimationPresentorViewControllerAnimatedTransitioning()
    let customAnimationDismisserViewControllerAnimatedTransitioning = CustomAnimationDismisserViewControllerAnimatedTransitioning()

    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissButton), for: .touchUpInside)
        return button
    }()

    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCaptureButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = self

        setUpCaptureSession()

        addAllSubviews()
        setUpAllConstraints()
    }

    override var prefersStatusBarHidden: Bool { return true }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentorViewControllerAnimatedTransitioning
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisserViewControllerAnimatedTransitioning
    }

    func addAllSubviews() {
        view.addSubview(dismissButton)
        view.addSubview(captureButton)
    }

    func setUpAllConstraints() {
        setUpDismissButton()
        setUpCaptureButton()
    }

    fileprivate func setUpDismissButton() {
        dismissButton.setConstraintsWithAnchors(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 50, height: 50)
    }

    fileprivate func setUpCaptureButton() {
        captureButton.setConstraintsWithAnchors(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    fileprivate func setUpCaptureSession() {
        let captureSession = AVCaptureSession()
        // Set up inputs
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)  else { return }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let error {
            print("Failed to get camera input:", error.localizedDescription)
        }
        // Set up outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        // Set up output previews
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame

        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    @objc fileprivate func handleCaptureButton() {
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else { return }
        //use your image data
        let previewImage = UIImage(data: imageData)
        let previewContainerView = CameraPreviewContainerView()

        previewContainerView.previewImageView.image = previewImage
        view.addSubview(previewContainerView)
        previewContainerView.setConstraintsWithAnchors(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        print("Finish processing photo sample buffer...")
    }

    @objc fileprivate func handleDismissButton() {
        dismiss(animated: true, completion: nil)
    }

}
