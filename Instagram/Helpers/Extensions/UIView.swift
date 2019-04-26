//
//  UIView.swift
//  Instagram
//
//  Created by José Pinto on 3/30/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

extension UIView {
    func setConstraintsWithAnchors(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat?, paddingLeft: CGFloat?, paddingBottom: CGFloat?, paddingRight: CGFloat?, width: CGFloat, height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top, let paddingTop = paddingTop {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left, let paddingLeft = paddingLeft {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom, let paddingBottom = paddingBottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right, let paddingRight = paddingRight {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
