//
//  UITextView.swift
//  Instagram
//
//  Created by José Pinto on 4/12/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit

extension UITextView: UITextViewDelegate {

    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }

    public var placeholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLbl = self.viewWithTag(50) as? UILabel {
                placeholderText = placeholderLbl.text
            }

            return placeholderText
        }
        set {
            if let placeholderLbl = self.viewWithTag(50) as! UILabel? {
                placeholderLbl.text = newValue
                placeholderLbl.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }

    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLbl = self.viewWithTag(50) as? UILabel {
            placeholderLbl.isHidden = self.text.count > 0
        }
    }

    private func resizePlaceholder() {
        if let placeholderLbl = self.viewWithTag(50) as! UILabel? {
            let x = self.textContainer.lineFragmentPadding
            let y = self.textContainerInset.top - 2
            let width = self.frame.width - (x * 2)
            let height = placeholderLbl.frame.height

            placeholderLbl.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }

    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLbl = UILabel()

        placeholderLbl.text = placeholderText
        placeholderLbl.sizeToFit()

        placeholderLbl.font = self.font
        placeholderLbl.textColor = UIColor.lightGray
        placeholderLbl.tag = 50

        placeholderLbl.isHidden = self.text.count > 0

        self.addSubview(placeholderLbl)
        self.resizePlaceholder()
        self.delegate = self
    }

}
