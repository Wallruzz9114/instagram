//
//  PhotoSelectorViewController.swift
//  Instagram
//
//  Created by José Pinto on 4/3/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let cellID = "cellID"
    let headerID = "headerID"
    var selectedImage: UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]()

    var photoSelectorHeadercollectionViewcell: PhotoSelectorHeaderCollectionViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white

        // Set up Cancel and Next buttons on top
        setUpNavigationButtons()

        // Register a custome cell view and header
        collectionView?.register(PhotoSelectorCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.register(PhotoSelectorHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)

        // Display Photos
        fetchPhotos()
    }

    // Selection of cell inside the collection view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView?.reloadData()
        // Scroll back up when selecting a cell
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    // Vertical spacing between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // Horizontal spacing between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // Cells size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }

    // Number of cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    // Cell declaration
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoSelectorCollectionViewCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }

    // Header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }

    // Header vertical spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }

    // Header declaration
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! PhotoSelectorHeaderCollectionViewCell

        self.photoSelectorHeadercollectionViewcell = header

        // Set header to display selected image
        header.photoImageView.image = selectedImage

        // Set a much larger (better resolution) image for header
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]

                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 700, height: 700)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, info) in
                    header.photoImageView.image = image
                }
            }
        }

        return header
    }

    // Hide status bar
    override var prefersStatusBarHidden: Bool { return true }

    fileprivate func setUpNavigationButtons() {
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissPhotoSelector))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }

    fileprivate func fetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        // Show most recent photos first
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]

        return fetchOptions
    }

    fileprivate func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions())

        // Put this part in a background thread so that the UI doesn't hang
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                // Access assets
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()

                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        // Add image to array
                        self.images.append(image)
                        self.assets.append(asset)
                        // Set the header to display the first image by default
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }

                    // Reload data
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            }
        }
    }

    @objc func dismissPhotoSelector() {
        dismiss(animated: true, completion: nil)
    }

    @objc func handleNext() {
        let sharePhotoViewController = SharePhotoViewController()
        sharePhotoViewController.selectedImage = photoSelectorHeadercollectionViewcell?.photoImageView.image
        navigationController?.pushViewController(sharePhotoViewController, animated: true)
    }

}
