//
//  TestController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/07/2023.
//

import UIKit

class TestController: UIViewController {
    
    let commentTextView: CommentTextView = {
        let view = CommentTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        view.addSubview(commentTextView)

        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        commentTextView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.safeAreaLayoutGuide.leadingAnchor,
                               trailing: view.safeAreaLayoutGuide.trailingAnchor)
    }
    
    
    

    
}
