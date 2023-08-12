//
//  ProfileHeaderCollectionViewCell.swift
//  Instagram Clone
//
//  Created by Sweety on 19/07/2023.
//

import UIKit



class ProfileHeaderCollectionViewCell: UICollectionViewCell {
    
    var currentIGUser: InstagramUser?
    
    
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
    
    let topSeparateLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()
    
    lazy var viewSettingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [gridViewButton, listViewButton, ribbonViewButton])
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let gridViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    let listViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    let ribbonViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    let bottomSeparateLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()
    

    
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
    
    enum formatType {
        case post, follower, following
    }
    
    var buttonStyle: buttonFollowingState? {
        didSet {
            updateButtonUI()
        }
    }
    
    enum buttonFollowingState {
        case followed, unfollow
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(editProfileButton)
        contentView.addSubview(topSeparateLine)
        contentView.addSubview(viewSettingStackView)
        contentView.addSubview(bottomSeparateLine)
        
        
        configureAutoLayout()
    }
    
    func setProfileImage(imageUrl: String) {  // called from layoutSubviews
        APICaller.shared.fetchImage(fromUrl: imageUrl) { [weak self] result in
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
    
    private func handleButtonStyle(with follows: FollowViewModel) {
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
    
    @objc private func didTapEditProfileButton() {
        
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
    
    func configure(with follow: FollowViewModel?, igUser: InstagramUser?) {
        
        if let follow = follow,
           let igUser = igUser {
            
            postCount = follow.total_post
            followerCount = follow.follower_uuid.count
            followingCount = follow.following_uuid.count
            currentIGUser = igUser
            setProfileImage(imageUrl: currentIGUser?.profile_image_url ?? "")

            guard let sessionUserUid = SessionManager.shared.getUser()?.user_uuid else {
                print("sessionUserUid is nil!")
                return
            }
            
            if igUser.user_uuid != sessionUserUid { // if not self profile
                handleButtonStyle(with: follow)
            }
            
        }
        
    }
    
    func configureAutoLayout() {
        
        profileImageView.anchor(top: contentView.topAnchor,
                                leading: contentView.leadingAnchor,
                                topConstant: 12,
                                leadingConstant: 12,
                                width: 80, height: 80)
        
        stackView.anchor(top: contentView.safeAreaLayoutGuide.topAnchor,
                         leading: profileImageView.trailingAnchor,
                         trailing: contentView.trailingAnchor,
                         topConstant: 12, leadingConstant: 12, TrailingConstant: -12,
                         height: 50)
        
        editProfileButton.anchor(top: stackView.bottomAnchor,
                                 leading: profileImageView.trailingAnchor,
                                 bottom: profileImageView.bottomAnchor,
                                 trailing: contentView.trailingAnchor,
                                 leadingConstant: 12, TrailingConstant: -12)
        
        
        topSeparateLine.anchor(top: profileImageView.bottomAnchor,
                               leading: contentView.leadingAnchor,
                               trailing: contentView.trailingAnchor,
                               topConstant: 20, height: 0.5)
        viewSettingStackView.anchor(top: topSeparateLine.bottomAnchor,
                                    leading: contentView.leadingAnchor,
                                    trailing: contentView.trailingAnchor,
                                    height: 44)
        bottomSeparateLine.anchor(top: viewSettingStackView.bottomAnchor,
                                  leading: contentView.leadingAnchor,
                                  trailing: contentView.trailingAnchor,
                                  height: 0.5)
        
        
        
        
    }
}
