//
//  MainTabBarController.swift
//  Instagram
//
//  Created by José Pinto on 3/30/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    // Disable selecting view controllers when tapping tab bar buttons
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let addPhotoButtonIndex = viewControllers?.index(of: viewController)

        if addPhotoButtonIndex == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorCollectionViewController = PhotoSelectorCollectionViewController(collectionViewLayout: layout)
            // Add navigation controller to add photo view controller (so that we can cancel)
            let navigationController = UINavigationController(rootViewController: photoSelectorCollectionViewController)

            present(navigationController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        // If user isn't logged in, show the login screen
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let signInViewController = SignInViewController()
                let navigationController: UINavigationController = UINavigationController(rootViewController: signInViewController)
                self.present(navigationController, animated: true, completion: nil)
            }
            return
        }

        setUpViewControllers()
    }

    func setUpViewControllers() {
        // Create home view controller with home icon
        let homeViewNavigationController = createViewNavigationControllerFrom(controller: HomePostCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()), image: #imageLiteral(resourceName: "home_unselected"), seletedImage: #imageLiteral(resourceName: "home_selected"))
        // Search view controller
        let searchViewNavigationController = createViewNavigationControllerFrom(controller: SearchCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()), image: #imageLiteral(resourceName: "search_unselected"), seletedImage: #imageLiteral(resourceName: "search_selected"))
        // Create the profile view controller
        let userProfileViewNavigationController = createUserProfileViewNavigationControllerFrom(layout: UICollectionViewFlowLayout(), image: #imageLiteral(resourceName: "profile_unselected"), seletedImage: #imageLiteral(resourceName: "profile_selected"))
        // Create add view controller
        let addPhotoViewNavigationController = createViewNavigationControllerFrom(controller: UIViewController(), image: #imageLiteral(resourceName: "plus_unselected"), seletedImage: #imageLiteral(resourceName: "plus_unselected"))
        // Likes view controller
        let likesViewNavigationController = createViewNavigationControllerFrom(controller: UIViewController(), image: #imageLiteral(resourceName: "like_unselected"), seletedImage: #imageLiteral(resourceName: "like_selected"))

        // Change tab bar color
        tabBar.tintColor = UIColor.black
        viewControllers = [homeViewNavigationController, searchViewNavigationController, addPhotoViewNavigationController, likesViewNavigationController, userProfileViewNavigationController]

        // Modify tab bar insets
        guard let tabBarItems = tabBar.items else { return }
        for item in tabBarItems {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }

    // Create navigation view controller from UIViewController
    fileprivate func createViewNavigationControllerFrom(controller: UIViewController, image: UIImage?, seletedImage: UIImage?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.selectedImage = seletedImage
        return navigationController
    }

    // Create navigation view controller from UICollectionViewFlowLayout (For profile page)
    fileprivate func createUserProfileViewNavigationControllerFrom(layout: UICollectionViewFlowLayout, image: UIImage?, seletedImage: UIImage?) -> UINavigationController {
        // Create the profile view controller
        let userProfileViewController: UIViewController = UserProfileCollectionViewController(collectionViewLayout: layout)
        // Add a navigation bar
        let userProfileViewNavigationController: UINavigationController = UINavigationController(rootViewController: userProfileViewController)
        //Add tab bar icon
        userProfileViewNavigationController.tabBarItem.image = image
        userProfileViewNavigationController.tabBarItem.selectedImage = seletedImage

        return userProfileViewNavigationController
    }

}
