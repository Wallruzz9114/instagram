//
//  Post.swift
//  Instagram
//
//  Created by José Pinto on 4/12/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

struct Post {

    var postID: String?

    let user: User
    let imageURL: String
    let caption: String
    let createdAt: Date

    var hasBeenLiked: Bool = false

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""

        let secondsFrom1970 = dictionary["created_at"] as? Double ?? 0
        self.createdAt = Date(timeIntervalSince1970: secondsFrom1970)
    }

}
