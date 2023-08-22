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
    func didFinishConfigCV()
}

class XLViewController: ButtonBarPagerTabStripViewController {
    
    var currentIGUser: InstagramUser
    
    weak var xlDelegate: XLViewControllerDelegate?
    
    var posts = [Post]()
    var viewModels = [PostViewModel]()

    override func viewDidLoad() {
        configureButtonBarStyle()
        super.viewDidLoad()

        setupMenuIndicator()
        
    }
    
    init(currentIGUser: InstagramUser) {
        
        self.currentIGUser = currentIGUser
        super.init(nibName: nil, bundle: nil)
        
        self.fetchPost() { [weak self] posts in
            
            self?.posts = posts
            self?.configureViewModels()
            self?.xlDelegate?.didFetchPost()
        }
    }
    
    func fetchPost() {
        self.fetchPost() { [unowned self] posts in
            
            self.posts.removeAll()
            self.viewModels.removeAll()
            self.posts = posts
            self.configureViewModels()
            
            for viewController in self.viewControllers {
                DispatchQueue.main.async {
                    if let collectionView = viewController.view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
                        
                            collectionView.reloadData()
                        }
                }
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    private func fetchPost(completion: @escaping ([Post]) -> Void) {

        
        APICaller.shared.fetchPersonalPost(withUserUID: self.currentIGUser.user_uuid) { result in
            switch result {
            case .success(let model):
                completion(model)
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
            viewModels.append(PostViewModel(post_id: post.post_id,
                                            poster_name: post.post_username,
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
    

    func didFinishConfigCV() {
        
        xlDelegate?.didFinishConfigCV()
    }
    
}
