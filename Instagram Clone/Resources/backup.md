//
//  xlViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 01/08/2023.
//

import XLPagerTabStrip
import UIKit

protocol XLViewControllerDelegate: AnyObject {
    func didChangePage(_ fromIndex: Int, _ toIndex: Int)
}

class XLViewController: ButtonBarPagerTabStripViewController {
    
    weak var xlDelegate: XLViewControllerDelegate?
    
    var post = [Post]()

    override func viewDidLoad() {
        configureButtonBarStyle()
        
        super.viewDidLoad()

        setupMenuIndicator()
        fetchPost()
    }
    
    private func fetchPost() {
        
        guard let sessionUserUID = SessionManager.shared.getUser()?.user_uuid else {
            print("sessionUserUID is nil from xlViewController")
            return
        }
        
        APICaller.shared.fetchPersonalPost(withUserUID: sessionUserUID) { [weak self] result in
            switch result {
            case .success(let model):
                self?.post = model
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    private func configureButtonBarStyle() {
        settings.style.buttonBarBackgroundColor = .systemBackground
        settings.style.buttonBarItemBackgroundColor = .systemBackground
        
        settings.style.buttonBarMinimumLineSpacing = 0
        
        settings.style.selectedBarHeight = 2
        settings.style.selectedBarBackgroundColor = UIColor.black
    }

    
    private func setupMenuIndicator() {
        changeCurrentIndexProgressive = { [weak self] oldCell, newCell, progressPercentage, changeCurrentIndex, animated in
            
            guard changeCurrentIndex == true else { return }
            newCell?.imageView.tintColor = .black
            oldCell?.imageView.tintColor = .lightGray
        }
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let gridVC = GridViewController()
        let ListVC = ListViewController()
        
        return [gridVC, ListVC]
    }
    
    
    
    override func updateIndicator(for viewController: PagerTabStripViewController,
                                  fromIndex: Int,
                                  toIndex: Int,
                                  withProgressPercentage progressPercentage: CGFloat,
                                  indexWasChanged: Bool) {
        
        super.updateIndicator(for: viewController,
                              fromIndex: fromIndex,
                              toIndex: toIndex,
                              withProgressPercentage: progressPercentage,
                              indexWasChanged: indexWasChanged)
        
        guard indexWasChanged == true else { return }
        

        xlDelegate?.didChangePage(fromIndex, toIndex)
    }
}
