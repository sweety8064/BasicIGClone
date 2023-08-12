//
//  PlaceHolderTextView.swift
//  Instagram Clone
//
//  Created by Sweety on 26/05/2023.
//

import UIKit

class PlaceHolderTextView: UITextView {
    
    let placeHolder: UILabel = {
        let label = UILabel()
        label.text = "Add a caption..."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        delegate = self
        
        addSubview(placeHolder)
        
        placeHolder.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        placeHolder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        placeHolder.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        placeHolder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}

extension PlaceHolderTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolder.isHidden = !text.isEmpty
    }
  
}

