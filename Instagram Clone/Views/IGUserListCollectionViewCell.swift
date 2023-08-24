//
//  IGUserListCollectionViewCell.swift
//  Instagram Clone
//
//  Created by Sweety on 24/08/2023.
//

import UIKit

class IGUserListCollectionViewCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user")
        imageView.layer.cornerRadius = 50 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton()
        button.setTitle("Loading", for: .normal)
        button.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.layer.backgroundColor = UIColor(hex: 0xEFEFEF).cgColor
        button.layer.cornerRadius = 32 / 4 // 8 radius
        return button
    }()
    
    var isFollowingBack: Bool? {
        didSet {
            updateButtonStyle()
        }
    }
    
    var sessionUserUID: String?
    var currentUserUUID: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(followButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapFollowButton() {
        if let isFollowingBack = isFollowingBack,
           let sessionUserUID = sessionUserUID,
           let currentUserUUID = currentUserUUID {
            
            let json = [
                "followerUUID": sessionUserUID,
                "followingUUID": currentUserUUID
            ]
            
            APICaller.shared.addFollowing(with: json) { result in
                
            }
            
            
            self.isFollowingBack = !isFollowingBack
            updateButtonStyle()
        }
    }
    
    private func updateButtonStyle() {
        if let isFollowingBack = isFollowingBack {
            
            if isFollowingBack {
                followButton.layer.backgroundColor = UIColor(hex: 0xEFEFEF).cgColor
                followButton.setTitle("Following", for: .normal)
                followButton.setTitleColor(.black, for: .normal)
            } else {
                followButton.layer.backgroundColor = UIColor(hex: 0x0097FD).cgColor
                followButton.setTitle("Follow", for: .normal)
                followButton.setTitleColor(.white, for: .normal)
            }
        } else { // if session user appear on iguserlist
            followButton.isEnabled = false
            followButton.layer.backgroundColor = UIColor(hex: 0xEFEFEF).cgColor
            followButton.setTitle("Me", for: .normal)
            followButton.setTitleColor(.black, for: .normal)
        }
    }
    
    func configureAutoLayout() {
        profileImageView.anchor(leading: contentView.leadingAnchor, leadingConstant: 10)
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        usernameLabel.anchor(top: contentView.topAnchor,
                             leading: profileImageView.trailingAnchor,
                             bottom: contentView.bottomAnchor,
                             trailing: followButton.leadingAnchor,
                             leadingConstant: 8)
        
        followButton.anchor(trailing: contentView.trailingAnchor, TrailingConstant: -20, width: 105, height: 32)
        followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
    }
    
    func configure(with user: IGUserFollowViewModel) {
        currentUserUUID = user.user_uuid
        usernameLabel.text = user.name
        profileImageView.sd_setImage(with: URL(string: user.profile_image_url))
        
        if let sessionUserUID = sessionUserUID {
            if sessionUserUID == user.user_uuid {
                updateButtonStyle()
            } else {
                isFollowingBack = user.is_following_back
            }
        }
        
        
        
        
        
    }
}
