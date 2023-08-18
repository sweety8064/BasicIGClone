//
//  PlaceHolderTextView.swift
//  Instagram Clone
//
//  Created by Sweety on 26/05/2023.
//

import UIKit

class PlaceHolderTextView: UITextView {
    
    let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        delegate = self
        
        addSubview(placeHolderLabel)
        
        placeHolderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        placeHolderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        placeHolderLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        placeHolderLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}

extension PlaceHolderTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = !text.isEmpty
    }
  
}

