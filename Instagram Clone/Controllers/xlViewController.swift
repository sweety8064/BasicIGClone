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
    func didFetchPost()
}

class XLViewController: ButtonBarPagerTabStripViewController {
    
    var currentIGUser: InstagramUser?
    
    weak var xlDelegate: XLViewControllerDelegate?
    
    var posts = [Post]()
    var viewModels = [PostViewModel]()

    override func viewDidLoad() {
        configureButtonBarStyle()
        super.viewDidLoad()

        setupMenuIndicator()
        
    }
    
    
    private func fetchPost(completion: (([Post]) -> Void)? = nil) {
        
        guard let currentIGUserUID = self.currentIGUser?.user_uuid else {
            print("currentIGUser is nil from xlViewController")
            return
        }
        
        APICaller.shared.fetchPersonalPost(withUserUID: currentIGUserUID) { [weak self] result in
            switch result {
            case .success(let model):
                completion?(model)
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
        gridVC.dataSource = self
        let listVC = ListViewController()
        listVC.dataSource = self
        
        return [gridVC, listVC]
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
    
    func configureViewModels() {
        for post in posts {
            viewModels.append(PostViewModel(poster_name: post.post_username,
                                            post_image_url: post.image_url,
                                            user_image_url: post.user_image_url,
                                            total_like: post.total_like,
                                            caption: post.caption,
                                            post_date_utc0: post.post_date_utc0,
                                            user_islike: post.user_islike))
            
            
        }
        
    }
}

extension XLViewController: GridListViewControllerDataSource {
        
    func fetchProfilePost() -> [PostViewModel] {
        self.xlDelegate?.didFetchPost() // for updateUnderlaySVContentSize()
        return self.viewModels
    }
    
    func initProfilePost(completion: @escaping () -> Void) {
        fetchPost() { [weak self] posts in
            self?.posts = posts
            self?.configureViewModels()
            completion()
        }
    }
}
