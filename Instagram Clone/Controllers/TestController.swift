//
//  TestController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/07/2023.
//

import UIKit

class TestController: UIViewController, UIScrollViewDelegate {
    
    let xlVC: XLViewController = {
        let vc = XLViewController()
        return vc
    }()
    
    lazy var sv: UIScrollView = {
        let sv = UIScrollView()
        sv.contentSize = CGSize(width: view.bounds.width, height: 2000)
        return sv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        sv.delegate = self
        view.addSubview(sv)
        
        sv.backgroundColor = .gray
        
        view.backgroundColor = .systemBackground
        addChild(xlVC)
        sv.addSubview(xlVC.view)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sv.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        xlVC.view.frame = CGRect(x: 0, y: sv.safeAreaInsets.top, width: view.bounds.width, height: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        
        print(view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        print(xlVC.buttonBarView.frame.height)
        print(xlVC.view.frame.height - xlVC.buttonBarView.frame.height)
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
    }
    
}
