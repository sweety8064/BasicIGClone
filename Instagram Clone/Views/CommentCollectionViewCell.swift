//
//  CommentCollectionViewCell.swift
//  Instagram Clone
//
//  Created by Sweety on 16/08/2023.
//

import UIKit
import SDWebImage

class CommentCollectionViewCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40 / 2
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "user")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let messageContent: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.textContainer.lineFragmentPadding = 0 // remove padding in original textView
        textView.font = .systemFont(ofSize: 14)
        return textView
    }()
    
    let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(messageContent)
        contentView.addSubview(timeAgoLabel)
        
        profileImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor,
                                topConstant: 8, leadingConstant: 8,
                                width: 40, height: 40)

        messageContent.anchor(top: contentView.topAnchor,
                              leading: profileImageView.trailingAnchor,
                              bottom: timeAgoLabel.topAnchor,
                              trailing: contentView.trailingAnchor,
                              topConstant: 4, leadingConstant: 8, TrailingConstant: -4)

        timeAgoLabel.anchor(leading: profileImageView.trailingAnchor, bottom: contentView.bottomAnchor,
                            leadingConstant: 8)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with comment: CommentViewModel) {
        
        messageContent.attributedText = comment.formatedContent
        timeAgoLabel.text = comment.timeAgo
        profileImageView.sd_setImage(with: URL(string: comment.user_image_url))
        
    }
    
    

}
