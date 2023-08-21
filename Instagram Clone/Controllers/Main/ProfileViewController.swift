//
//  ProfileViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/05/2023.
//

import UIKit
import FirebaseAuth

protocol ProfileViewControllerDelegate: AnyObject {
    func didSignOut()
}

class ProfileViewController: UIViewController {
    
    weak var delegate: ProfileViewControllerDelegate?
    
    var currentIGUser: InstagramUser?
    
    let underlayScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    lazy var containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user")
        imageView.layer.cornerRadius = 80 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var postCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.attributedText = formatedString(with: postCount, type: .post)
        return label
    }()
    
    lazy var followerCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.attributedText = formatedString(with: followerCount, type: .follower)
        return label
    }()
    
    lazy var followingCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.attributedText = formatedString(with: followingCount, type: .following)
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [postCountLabel, followerCountLabel, followingCountLabel]
        )
        return stackView
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        return button
    }()
    
    let separateLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()
    
    lazy var xlViewController: XLViewController = {
        let vc = XLViewController(currentIGUser: currentIGUser!)
        return vc
    }()
    
    var buttonStyle: buttonFollowingState? {
        didSet {
            updateButtonUI()
        }
    }
    
    enum formatType {
        case post, follower, following
    }
    
    enum buttonFollowingState {
        case followed, unfollow
    }
    
    var postCount = 0 {
        didSet {
            postCountLabel.attributedText = formatedString(with: postCount, type: .post)
        }
    }
    var followerCount = 0 {
        didSet {
            followerCountLabel.attributedText = formatedString(with: followerCount, type: .follower)
        }
    }
    var followingCount = 0 {
        didSet {
            followingCountLabel.attributedText = formatedString(with: followingCount, type: .following)
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    

    
//MARK: - viewcontroller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        
        if currentIGUser == nil {
            currentIGUser = SessionManager.shared.getUser()
        }
        
        containerScrollView.refreshControl = refreshControl
        
        

        view.addSubview(underlayScrollView)
        underlayScrollView.addSubview(containerScrollView)
        containerScrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(profileImageView)
        headerView.addSubview(stackView)
        headerView.addSubview(editProfileButton)
        headerView.addSubview(separateLine)
          
        setProfileImage(imageUrl: currentIGUser?.profile_image_url ?? "")
        fetchUserProfile()
        configureNavigationBar()
        configureAutoLayout()
        
        xlViewController.xlDelegate = self // xlViewController will first init at here
    }
    
    private func updateUnderlaySVContentSize() {
        
        guard let nearestScrollView = getNearestScrollViewInSubView() else { fatalError() }
        let buttonBarViewHeight = xlViewController.buttonBarView.frame.height
        
        underlayScrollView.contentSize.height = max(headerView.frame.height + nearestScrollView.contentSize.height + buttonBarViewHeight, view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom + headerView.frame.height)
        
        
    }
    
    private func getNearestScrollViewInSubView(forIndex: Int? = nil) -> UIScrollView? {
        
        let index: Int?
        
        if let forIndex = forIndex {
            index = forIndex
        } else {
            index = self.xlViewController.currentIndex
        }
        
        
        if let scrollView = self.xlViewController.viewControllers[index!].view.subviews.first(where: {$0 is UIScrollView}) as? UIScrollView{
            
            return scrollView
            
        }
        
        return nil
    }
    
    
    
    
    private func fetchUserProfile() {
        guard let igUserUid = currentIGUser?.user_uuid else {
            print("currentUserUID is nil!")
            return
        }
        
        guard let sessionUserUid = SessionManager.shared.getUser()?.user_uuid else {
            print("sessionUserUid is nil!")
            return
        }
        
        APICaller.shared.fetchUserProfile(withUserUID: igUserUid) { [weak self] result in
            switch result {
            case .success(let follows):
                DispatchQueue.main.async {
                    self?.postCount = follows.total_post
                    self?.followerCount = follows.follower_uuid.count
                    self?.followingCount = follows.following_uuid.count
                    
                    if igUserUid != sessionUserUid {
                        self?.handleButtonStyle(with: follows)
                    }
                    
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleButtonStyle(with follows: Follow) {
        guard let sessionUser = SessionManager.shared.getUser() else {
            print("sessionUser is nil")
            return
        }
        
        let isUserAlreadyFollow = follows.follower_uuid.contains(sessionUser.user_uuid)
        
        editProfileButton.addTarget(self, action: #selector(didTapEditProfileButton), for: .touchUpInside)
        
        if isUserAlreadyFollow {
            self.buttonStyle = .followed
        } else {
            self.buttonStyle = .unfollow
        }
    }
    
    private func updateButtonUI() {
        switch buttonStyle {
        case .followed:
            editProfileButton.setTitle("Unfollow", for: .normal)
            editProfileButton.setTitleColor(.black, for: .normal)
            editProfileButton.backgroundColor = .white
        case .unfollow:
            editProfileButton.setTitle("Follow", for: .normal)
            editProfileButton.setTitleColor(.white, for: .normal)
            editProfileButton.backgroundColor = UIColor.mainBlue
            editProfileButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        case .none:
            editProfileButton.setTitle("loading", for: .normal)
        }
    }
    
    
    
    func configureAutoLayout() {
        
        underlayScrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                  leading: view.leadingAnchor,
                                  bottom: view.bottomAnchor,
                                  trailing: view.trailingAnchor)
        
        containerScrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                   leading: view.leadingAnchor,
                                   bottom: view.bottomAnchor,
                                   trailing: view.trailingAnchor)
        
        contentView.anchor(top: containerScrollView.topAnchor,
                           leading: containerScrollView.leadingAnchor,
                           bottom: containerScrollView.bottomAnchor,
                           trailing: containerScrollView.trailingAnchor)
        contentView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor).isActive = true
        
        headerView.anchor(top: contentView.topAnchor,
                          leading: contentView.leadingAnchor,
                          trailing: contentView.trailingAnchor,
                          height: 113)
        
        profileImageView.anchor(top: headerView.topAnchor,
                                leading: headerView.leadingAnchor,
                                topConstant: 12,
                                leadingConstant: 12,
                                width: 80, height: 80)
        
        stackView.anchor(top: headerView.topAnchor,
                         leading: profileImageView.trailingAnchor,
                         trailing: view.trailingAnchor,
                         topConstant: 12, leadingConstant: 12, TrailingConstant: -12,
                         height: 50)

        editProfileButton.anchor(top: stackView.bottomAnchor,
                                 leading: profileImageView.trailingAnchor,
                                 bottom: profileImageView.bottomAnchor,
                                 trailing: headerView.trailingAnchor,
                                 leadingConstant: 12, TrailingConstant: -12)


        separateLine.anchor(top: profileImageView.bottomAnchor,
                               leading: headerView.leadingAnchor,
                               trailing: headerView.trailingAnchor,
                               topConstant: 20, height: 0.5)

        
        
        
        
    }

    
    func configureNavigationBar() {
        navigationItem.title = currentIGUser?.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapNBSettings))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func didTapNBSettings() {
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] action in
            do {
                try Auth.auth().signOut()
            } catch {
                print(error.localizedDescription)
            }
            
            self?.delegate?.didSignOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        
        let alert = UIAlertController()
        
        alert.addAction(signOutAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    @objc func didTapEditProfileButton() {
        
        addFollow()
        
        switch buttonStyle {
        case .followed:
            buttonStyle = .unfollow
        case .unfollow:
            buttonStyle = .followed
        case .none:
            print("nothing")
        }
        
    }
    
    func configure(with igUser: InstagramUser) {
        currentIGUser = igUser
        
    }
    
    func setProfileImage(imageUrl: String) {
        APICaller.shared.fetchImage(fromUrl: imageUrl) { [weak self]result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func addFollow() {
        guard let followingUUID = currentIGUser?.user_uuid,
              let followerUUID = SessionManager.shared.getUser()?.user_uuid else {
            print("current uid is nil from didTapEditProfileButton")
            return
        }
        
        
        let data = [
            "followerUUID": followerUUID,
            "followingUUID": followingUUID
        ]
        
        APICaller.shared.addFollowing(with: data) { [weak self] success in
            if success {
                DispatchQueue.main.async { [weak self] in
                    switch self?.buttonStyle {
                    case .followed:
                        self?.followerCount += 1
                    case .unfollow:
                        self?.followerCount -= 1
                    case .none:
                        print("nothing")
                    }
                }
                
            }
        }
    }
    
    func formatedString(with count: Int, type: formatType) -> NSMutableAttributedString {
        
        let attributeText = NSMutableAttributedString(
            string: "\(count)\n",
            attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        )
        
        switch type {
        case .post:
            attributeText.append(NSAttributedString(
                string: "post",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            )
        case .follower:
            attributeText.append(NSAttributedString(
                string: "followers",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            )
        case .following:
            attributeText.append(NSAttributedString(
                string: "followings",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
            )
        }
        return attributeText
    }

    deinit {
        print("ProfileVC deinit!")
        NotificationCenter.default.removeObserver(self)
    }
    
    var lastContentOffset: CGFloat  = 0
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { //underlayScrollView 1400 1800
        
        self.containerScrollView.contentOffset.y = scrollView.contentOffset.y

        if scrollView.contentOffset.y > headerView.frame.maxY { // if reach the headview height
            self.containerScrollView.contentOffset.y = headerView.frame.maxY // lock the container offset
            
            getNearestScrollViewInSubView()?.contentOffset.y = scrollView.contentOffset.y - headerView.frame.maxY

        }
        
        //========================== remove remain offset if scroll too fast ====================
        if lastContentOffset > headerView.frame.maxY {
            if scrollView.contentOffset.y < headerView.frame.maxY {
                getNearestScrollViewInSubView()?.contentOffset.y = 0
            }
        }
        
        lastContentOffset = scrollView.contentOffset.y
        //======================================================================================
        
        
    }
}



extension ProfileViewController: XLViewControllerDelegate {
    func didFetchPost() {
        
        DispatchQueue.main.async { [unowned self] in
            self.addChild(self.xlViewController)
            self.contentView.addSubview((self.xlViewController.view)!)
            self.didMove(toParent: self)
            
            self.xlViewController.view.anchor(top: self.headerView.bottomAnchor,
                                              leading: self.contentView.leadingAnchor,
                                              bottom: self.contentView.bottomAnchor,
                                              trailing: self.contentView.trailingAnchor,
                                              height: 715) // view - safeTopbottom - buttonBarHeight(44)
            
            
        }
        
    }
    
    func didChangePage(_ fromIndex: Int, _ toIndex: Int) {
        self.underlayScrollView.delegate = nil
        
        let temp = getNearestScrollViewInSubView(forIndex: toIndex)?.contentOffset.y
        updateUnderlaySVContentSize()
        underlayScrollView.contentOffset.y = (temp ?? 0) + containerScrollView.contentOffset.y
        
        self.underlayScrollView.delegate = self
        

        
        
    }
    
    func didFinishConfigCV() {
        updateUnderlaySVContentSize()
        underlayScrollView.delegate = self
    }
    

}


