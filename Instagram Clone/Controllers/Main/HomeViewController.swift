//
//  HomeViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/05/2023.
//
import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    var posts = [Post]()
    var viewModels = [PostViewModel]()
    var sessionUser: InstagramUser?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didScrollUpRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var collectionView = UICollectionView( //UICollectionViewCompositionalLayout(selectionProvider
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.createLayoutSection(section: sectionIndex)
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionUser = SessionManager.shared.getUser()
        
        setupNavigationBar()
        configureCollectionView()
        fetchPost()
        
        
        
    }
    
    func fetchPost(completion: (() -> Void)? = nil) {
        
        guard let uid = sessionUser?.user_uuid else {
            print("uid is nil")
            return
        }
        
        APICaller.shared.fetchPost(withUID: uid) { [weak self] result in
            switch result {
            case .success(let model):
                self?.posts.removeAll()
                self?.viewModels.removeAll()
                self?.posts = model
                self?.configureViewModels()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                completion?()  // to remove scrolling animation icon
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    

    
    func configureViewModels() {
        for post in posts {
            viewModels.append(PostViewModel(post_id: post.post_id,
                                            post_user_uuid: post.post_user_uuid,
                                            poster_name: post.post_username,
                                            post_image_url: post.image_url,
                                            user_image_url: post.user_image_url,
                                            total_like: post.total_like,
                                            caption: post.caption,
                                            post_date_utc0: post.post_date_utc0,
                                            user_islike: post.user_islike))
            
            
        }
        
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              leading: view.safeAreaLayoutGuide.leadingAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              trailing: view.safeAreaLayoutGuide.trailingAnchor)
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "postCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func didScrollUpRefresh() {
        fetchPost { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo")) // setup Instagram logo
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapNBCamera))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "inbox"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapNVMenu))
        
    }
    
    private func createLayoutSection(section: Int) -> NSCollectionLayoutSection {
        let section1: NSCollectionLayoutSection = {
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(600)), subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }()
        
        return section1
    }
    
    @objc private func didTapNVMenu() {
        
    }
    
    @objc private func didTapNBCamera() {
        
    }
    
    deinit {
        print("HomeVC deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }

}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as? PostCollectionViewCell else {
            print("cannot downcast to PostCollectionViewCell!")
            return UICollectionViewCell()
        }
        
        cell.delegate = self

        viewModels[indexPath.row].imageIsAvailable = { postImage in // set postImage when image is available
            DispatchQueue.main.async { // handle image available after cell create
                cell.userPostImageView.image = postImage
            }
        }
        
        viewModels[indexPath.row].userImageIsAvailable = { userImage in // set userProfileImage when image is available
            DispatchQueue.main.async {
                cell.userProfileView.image = userImage
            }
        }
        
        let post = viewModels[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    

    
}

extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: PostCollectionViewCellDelegate {
    func didTapOptionMenuButton(post_id: Int, post_user_uuid: String) {
        guard let sessionUser = sessionUser else { fatalError() }
        
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { [weak self] action in
            
            let json = [
                "post_id": post_id
            ]
            
            APICaller.shared.deletePost(with: json) { [weak self] error in
                DispatchQueue.main.async {
                    self?.fetchPost()
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        
        let alert = UIAlertController()
        
        if sessionUser.user_uuid == post_user_uuid { // enable delete option if owner
            alert.addAction(deletePostAction)
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    func didTapCommentButton(post_id: Int?) {
        
        let vc = CommentViewController()
        vc.post_id = post_id
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
        

    }
    
    func didTapLikeButton(for cell: PostCollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { // get indexpath of return cell
            print("cannot get indexPath!")
            return
        }
        
        guard let currentIGUser = sessionUser else {
            print("current user is nil!")
            return
        }
        

        //===================== update UI to prevent wrong value when scroll =================
        viewModels[indexPath.row].user_islike = cell.isLike
        viewModels[indexPath.row].total_like = cell.likeCount
        //self.collectionView?.reloadItems(at: [indexPath])
        //====================================================================================
        let post_id = posts[indexPath.row].post_id
        let like = toLike(userUID: currentIGUser.user_uuid, likePostUID: post_id)
        
        APICaller.shared.addLike(with: like) { success in
            
        }

    }
    
    func didTapLikeCounterButton(post_id: Int) {
        
        let followersListVC = FollowersListViewController(navigationBarTitle: "Likes")
        followersListVC.currentContainerHeight = 500
        followersListVC.post_id = post_id
        followersListVC.viewType = .like
        followersListVC.modalPresentationStyle = .overFullScreen
        present(followersListVC, animated: false)
        
    }
}

