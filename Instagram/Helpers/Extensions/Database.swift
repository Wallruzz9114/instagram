//
//  Database.swift
//  Instagram
//
//  Created by José Pinto on 4/16/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

extension Database {

    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // User data
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (error) in
            print("Failed to fetch user:", error.localizedDescription)
        }
    }

}
