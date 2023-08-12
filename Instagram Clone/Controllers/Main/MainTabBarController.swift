//
//  ViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 11/05/2023.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    
    var currentInstagramUser: InstagramUser?
    var didLoginHandler: ((User) -> Void)?
    var didPressHomeVC: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ========== handle user login =================
        
        SessionManager.shared.checkIsLogin { [weak self] isLogin in
            DispatchQueue.main.async { [weak self] in
                if isLogin {
                    self?.currentInstagramUser = SessionManager.shared.getUser()
                        self?.setupTabBarController()
                } else {
                    self?.presentLoginVC()
                }
                
            }
        }
        
    }
    
    func presentLoginVC() {
        let loginVC = LoginViewController()
        let navLoginVC = UINavigationController(rootViewController: loginVC)
        navLoginVC.modalPresentationStyle = .fullScreen
        present(navLoginVC, animated: true)
    }
    

    
    func setupTabBarController() {
        
        //============= tabbar appearance configuration =====================
        tabBar.tintColor = .systemRed   // turn the all tabbar icon into black
        tabBar.isTranslucent = false    // disable tabbar translucent
        
        //============= init the controller =====================
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = AddPhotoViewController()
        let vc4 = LikeViewController()
        let vc5 = ProfileViewController()
        
        vc5.delegate = self
        
        //============= define callback function =====================
        
        didPressHomeVC = { [weak vc1] in // if not weak "vc1" will hold by did
            if self.selectedIndex == 0 { // if view already at top
                if vc1?.collectionView.contentOffset == CGPoint(x: 0, y: 0) {
                    vc1?.refreshControl.refreshManually()
                } else {
                    UIView.animate(withDuration: 0.3) {
                        vc1?.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                        at: .top, animated: true) // scroll to top item
                    }
                }
            }
        }
        
        //============= embedded the controller into navigation controller  =====================
        
        let navVC1 = UINavigationController(rootViewController: vc1)
        let navVC2 = UINavigationController(rootViewController: vc2)
        let navVC3 = UINavigationController(rootViewController: vc3)
        let navVC4 = UINavigationController(rootViewController: vc4)
        let navVC5 = UINavigationController(rootViewController: vc5)
        
        //============= add the icon for tabbar item =====================
        
        navVC1.tabBarItem = UITabBarItem(title: "",     // no specifiy name will result remain icon only
                                         image: UIImage(named: "home_unselected"),
                                         selectedImage: UIImage(named: "home_selected"))
        navVC2.tabBarItem = UITabBarItem(title: "",
                                         image: UIImage(named: "search_unselected"),
                                         selectedImage: UIImage(named: "search_selected"))
        navVC3.tabBarItem = UITabBarItem(title: "",
                                         image: UIImage(named: "plus_unselected"),
                                         tag: 0)
        navVC4.tabBarItem = UITabBarItem(title: "",
                                         image: UIImage(named: "like_unselected"),
                                         selectedImage: UIImage(named: "like_selected"))
        navVC5.tabBarItem = UITabBarItem(title: "",
                                         image: UIImage(named: "profile_unselected"),
                                         selectedImage: UIImage(named: "profile_selected"))
        
        //============= adjust the icon position =====================
        
        navVC1.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        navVC2.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        navVC3.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        navVC4.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        navVC5.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        
        //============= for display tabbar in bottom =====================
        
        setViewControllers([navVC1, navVC2, navVC3, navVC4, navVC5], animated: true)
    }

}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool { // Active everytime when press a tabbar, if return false cannot move to selected tabbar
        
        //============= get index of a tabbar that pressed =====================
        guard let selectedTab = viewControllers?.firstIndex(of: viewController) else { return true }
        
        if selectedTab == 0 {
            didPressHomeVC?()
        } else if selectedTab == 2 {
            let vc = PhotoSelectorViewController()
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC, animated: true)
            return false
        }
        
        return true
    }
}



extension MainTabBarController: ProfileViewControllerDelegate {
    func didSignOut() {
        presentLoginVC()
    }
}

