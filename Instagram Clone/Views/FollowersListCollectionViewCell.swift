//
//  FollowersListCollectionViewCell.swift
//  Instagram Clone
//
//  Created by Sweety on 23/08/2023.
//

import UIKit

class FollowersListCollectionViewCell: UICollectionViewCell {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(separatorLineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configureAutoLayout() {
        profileImageView.anchor(leading: contentView.leadingAnchor, leadingConstant: 8)
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        usernameLabel.anchor(top: contentView.topAnchor,
                             leading: profileImageView.trailingAnchor,
                             bottom: contentView.bottomAnchor,
                             trailing: contentView.trailingAnchor,
                             leadingConstant: 8)
        
        separatorLineView.anchor(leading: usernameLabel.leadingAnchor,
                                 bottom: contentView.bottomAnchor,
                                 trailing: contentView.trailingAnchor,
                                 height: 0.5)
    }
    
    func configure(with user: InstagramUserViewModel) {
        usernameLabel.text = user.name
        profileImageView.image = user.profileImage
    }
}
