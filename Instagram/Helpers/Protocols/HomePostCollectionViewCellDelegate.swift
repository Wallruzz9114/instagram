//
//  HomePostCollectionViewCell.swift
//  Instagram
//
//  Created by José Pinto on 4/19/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

protocol HomePostCollectionViewCellDelegate {

    func onTapCommentButton(post: Post)
    func onTapLikeButton(for cell: HomePostCollectionViewCell)

}
