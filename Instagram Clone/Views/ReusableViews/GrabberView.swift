//
//  GrabberView.swift
//  Instagram Clone
//
//  Created by Sweety on 14/08/2023.
//

import Foundation
import UIKit

class GrabberView: UIView {
    
    let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let grabberView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .rgb(red: 194, green: 196, blue: 194)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor,
                               leading: leadingAnchor,
                               bottom: bottomAnchor,
                               trailing: trailingAnchor,
                               height: 20) // this decides entire view height
        
        containerView.addSubview(grabberView)
        grabberView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        grabberView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12).isActive = true
        grabberView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        grabberView.widthAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
