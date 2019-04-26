//
//  SearchCollectionViewController.swift
//  Instagram
//
//  Created by José Pinto on 4/16/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class SearchCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    let cellID = "cellID"
    var users = [User]()
    var filteredUsers = [User]()

    // search bar
    lazy var instagramSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search instagram..."
        // darker color
        searchBar.barTintColor = UIColor.gray
        searchBar.autocapitalizationType = .none
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(hexString: "#e6e6e6")
        searchBar.delegate = self
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
        // Add searchbar to navigation bar
        navigationItem.titleView = instagramSearchBar
        // Register cell with an id
        collectionView?.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        // Allow for scrolling
        collectionView?.alwaysBounceVertical = true
        // dismiss keyboard
        collectionView?.keyboardDismissMode = .onDrag
        // Fetch users
        fetchUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        instagramSearchBar.isHidden = false
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
        // Get rid of the searchbar
        instagramSearchBar.isHidden = true
        // Dismiss keyboard
        instagramSearchBar.resignFirstResponder()
        // fetch user profile
        let userProfileCollectionViewController = UserProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileCollectionViewController.userID = user.uid
        navigationController?.pushViewController(userProfileCollectionViewController, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredUsers = self.users
        } else {
            self.filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }

        self.collectionView?.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SearchCollectionViewCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }

    fileprivate func fetchUsers() {
        let reference = Database.database().reference().child("users")

        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }

            dictionaries.forEach({ (key, value) in
                // omit current user from search
                if key == Auth.auth().currentUser?.uid {
                    return
                }

                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)

                self.users.append(user)
            })

            self.users.sort(by: { (firstUser, secondUser) -> Bool in
                return firstUser.username.compare(secondUser.username) == .orderedAscending
            })

            self.filteredUsers = self.users
            self.collectionView?.reloadData()
        }) { (error) in
            print("failed to fetch users:", error.localizedDescription)
        }
    }

}
