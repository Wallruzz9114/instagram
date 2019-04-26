//
//  User.swift
//  Instagram
//
//  Created by José Pinto on 4/1/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

struct User {

    let uid: String
    let email: String
    let username: String
    let profileImageURL: String

    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageURL = dictionary["profile_picture_url"] as? String ?? ""
    }

}
