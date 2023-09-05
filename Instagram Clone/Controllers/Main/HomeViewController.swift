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
    
    let fetchLimit = 5
    var totalRecords = 0
    var isLoading = false
    var reachingEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionUser = SessionManager.shared.getUser()
        
        setupNavigationBar()
        configureCollectionView()
        fetchPost()
        
        
        
    }
    
    func fetchPost(cleanOldData: Bool = true, completion: (() -> Void)? = nil) {
        
        guard let uid = sessionUser?.user_uuid else {
            print("uid is nil")
            return
        }
        
        let json: [String: Any] = [
            "uid": uid,
            "offset": totalRecords
        ]
        
        APICaller.shared.fetchPost(withUID: json) { [weak self] result in
            switch result {
            case .success(let model):
                if cleanOldData || self?.totalRecords == 0 { // for initial data
                    self?.reachingEnd = false
                    self?.posts.removeAll()
                    self?.viewModels.removeAll()
                    self?.posts = model
                    self?.configureViewModels()
                    self?.totalRecords = model.count
                } else { // fetch next set of records
                    if model.count != self?.fetchLimit { // prevent unlimited loop when reach end
                        self?.reachingEnd = true
                    }
                    self?.posts.append(contentsOf: model)
                    self?.configureViewModels(fromSpecficPosts: model)
                    self?.totalRecords += model.count
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                completion?()  // to remove scrolling animation icon
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    

    
    func configureViewModels(fromSpecficPosts: [Post]? = nil) {
        
        if let posts = fromSpecficPosts {
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
        } else {
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
        totalRecords = 0
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

        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(600)))

        
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(600)),
            subitems: [item]
        )
        
        
        let section = NSCollectionLayoutSection(group: group)
        return section
        
        

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

//MARK: - UICollectionViewDataSource
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

//        viewModels[indexPath.row].imageIsAvailable = { postImage in // set postImage when image is available
//            DispatchQueue.main.async { // handle image available after cell create
//                cell.userPostImageView.image = postImage
//            }
//        }
//        
//        viewModels[indexPath.row].userImageIsAvailable = { userImage in // set userProfileImage when image is available
//            DispatchQueue.main.async {
//                cell.userProfileView.image = userImage
//            }
//        }
        
        let post = viewModels[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    

    
}

//MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let lastItem = posts.count - 1
        
        if indexPath.row == lastItem && !isLoading && !reachingEnd {
            isLoading = true
            fetchPost(cleanOldData: false) { [weak self] in
                self?.isLoading = false
            }
        }
    }
}

//MARK: - PostCollectionViewCellDelegate
extension HomeViewController: PostCollectionViewCellDelegate {
    func didTapOptionMenuButton(post_id: Int, post_user_uuid: String) {
        guard let sessionUser = sessionUser else { fatalError() }
        
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { [weak self] action in
            
            let json = [
                "post_id": post_id
            ]
            
            APICaller.shared.deletePost(with: json) { [weak self] error in
                DispatchQueue.main.async {
                    self?.totalRecords = 0
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
        
        let json: [String: Any] = [
            "likePostUID": posts[indexPath.row].post_id,
            "userUID": currentIGUser.user_uuid,
            "createDate": Date().getFormattedTime()
        ]
        
        APICaller.shared.addLike(with: json) { success in
            
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
    
    func didTapShowMore(for cell: PostCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { // get indexpath of return cell
            print("cannot get indexPath!")
            return
        }
        
        viewModels[indexPath.row].isCaptionExpanded = true
        
        collectionView.collectionViewLayout.invalidateLayout()

    }
}

