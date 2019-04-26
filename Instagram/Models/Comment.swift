//
//  Comment.swift
//  Instagram
//
//  Created by José Pinto on 4/20/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

struct Comment {

    let user: User

    let commenterID: String
    let text: String
    let createdAt: Date

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.commenterID = dictionary["op_id"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""

        let secondsFrom1970 = dictionary["created_at"] as? Double ?? 0
        self.createdAt = Date(timeIntervalSince1970: secondsFrom1970)
    }

}
