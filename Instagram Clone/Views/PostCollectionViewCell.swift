//
//  PostCollectionViewCell.swift
//  Instagram Clone
//
//  Created by Sweety on 05/06/2023.
//

import UIKit

protocol PostCollectionViewCellDelegate: AnyObject {
    func didTapLikeButton(for cell: PostCollectionViewCell)
    func didTapCommentButton(post_id: Int?)
    func didTapOptionMenuButton(post_id: Int, post_user_uuid: String)
    func didTapLikeCounterButton(post_id: Int)
    func didTapShowMore(for cell: PostCollectionViewCell)
    
}

class PostCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PostCollectionViewCellDelegate?
    
    var post_id: Int?
    var post_user_uuid: String?
    
    let postHeaderContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    let userProfileView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40 / 2   //cuz autolayout width and height = 40
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        imageView.image = UIImage(named: "user")
        return imageView
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()

        return label
    }()
    
    lazy var optionMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.addTarget(self, action: #selector(didTapOptionMenuButton), for: .touchUpInside)
        return button
    }()
    
    let userPostImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true    // prevent image overlapped view
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray
        return imageView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
        stackView.alignment = .top
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false  //spacing is the part of autolayout
        return stackView
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "comment"), for: .normal)
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send2"), for: .normal)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        return button
    }()
    
    lazy var likeCounterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("\(likeCount) Like", for: .normal)
        button.addTarget(self, action: #selector(didTapLikeCounterButton), for: .touchUpInside)
        return button
    }()
    
    lazy var postCaptionTextView: UITextView = {
        let label = UITextView()
        label.isScrollEnabled = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPostCaptionLabel)))
        label.textContainer.lineFragmentPadding = 0 // remove padding
        label.textContainer.maximumNumberOfLines = 2
        label.isSelectable = false
        label.textContainer.lineBreakMode = .byTruncatingTail // make string to ... if too much
        label.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return label
    }()
    
//    lazy var readMoreButton: UIButton = {
//        let button = UIButton()
//        button.titleLabel?.font = .systemFont(ofSize: 14)
//        button.setTitleColor(.gray, for: .normal)
//        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0.01, bottom: 0.01, right: 0)
//        button.addTarget(self, action: #selector(didTapReadMoreButton), for: .touchUpInside)
//        return button
//    }()
    
    let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    var isLike: Bool = false { // not computed property, more like observer
        didSet {
            if isLike {
                likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
            } else {
                likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
            }
        }
        
    }
    var likeCount: Int = 0 {
        didSet {
            likeCounterButton.setTitle("\(likeCount) Like", for: .normal)
        }
    }
    
    var sessionUserUID: String? {
        return SessionManager.shared.getUser()?.user_uuid
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(postHeaderContainer)       // must write "contentView" to display correctly
        postHeaderContainer.addSubview(userProfileView)
        postHeaderContainer.addSubview(userNameLabel)
        postHeaderContainer.addSubview(optionMenuButton)
        contentView.addSubview(userPostImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(bookmarkButton)
        contentView.addSubview(likeCounterButton)
        contentView.addSubview(postCaptionTextView)
        contentView.addSubview(timeAgoLabel)
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        
        configureAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    
    @objc private func didTapOptionMenuButton() {
        
        guard let post_id = post_id else {
            print("post_id is nil from didtapoptionmenubutton")
            return
        }
        
        if let post_user_uuid = self.post_user_uuid {
            delegate?.didTapOptionMenuButton(post_id: post_id, post_user_uuid: post_user_uuid)
        }
        
        
    }
    
    @objc func didTapPostCaptionLabel() {
        
        postCaptionTextView.textContainer.maximumNumberOfLines = 0
        
        postCaptionTextView.invalidateIntrinsicContentSize() // notice uikit to update UITextView
        delegate?.didTapShowMore(for: self)
        
    }
    
    @objc private func didTapLikeCounterButton() {
        if let post_id = post_id {
            delegate?.didTapLikeCounterButton(post_id: post_id)
        }
    }
    
    @objc private func didTapLikeButton() {
        
        if isLike {
            likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
        }
        
        handleLikeCount(!isLike)
        isLike = !isLike
        delegate?.didTapLikeButton(for: self)
    }
    
    @objc private func didTapCommentButton() {
        delegate?.didTapCommentButton(post_id: post_id)
    }
    
    private func handleLikeCount(_ isLike: Bool) {
        likeCount = isLike ? likeCount + 1 : likeCount - 1
        likeCounterButton.setTitle("\(likeCount) like", for: .normal)
    }
    
    private func configureAutoLayout() {
        postHeaderContainer.anchor(top: contentView.topAnchor,
                                   leading: contentView.leadingAnchor,
                                   trailing: contentView.trailingAnchor)
        userProfileView.anchor(top: postHeaderContainer.topAnchor,
                               leading: postHeaderContainer.leadingAnchor,
                               bottom: postHeaderContainer.bottomAnchor,
                               topConstant: 8,
                               leadingConstant: 8,
                               bottomConstant: -8,
                               width: 40,
                               height: 40)
        userNameLabel.anchor(top: postHeaderContainer.topAnchor,
                             leading: userProfileView.trailingAnchor,
                             bottom: postHeaderContainer.bottomAnchor,
                             trailing: optionMenuButton.leadingAnchor,
                             leadingConstant: 8)
        optionMenuButton.anchor(top: postHeaderContainer.topAnchor,
                                bottom: postHeaderContainer.bottomAnchor,
                                trailing: postHeaderContainer.trailingAnchor,
                                width: 44)
        userPostImageView.anchor(top: postHeaderContainer.bottomAnchor,
                                 leading: contentView.leadingAnchor,
                                 trailing: contentView.trailingAnchor,
                                 height: contentView.frame.width)
        stackView.anchor(top: userPostImageView.bottomAnchor,
                         leading: contentView.leadingAnchor,
                         topConstant: 12,
                         leadingConstant: 12)
        bookmarkButton.anchor(top: userPostImageView.bottomAnchor,
                              trailing: contentView.trailingAnchor,
                              topConstant: 12,
                              TrailingConstant: -12)
        likeCounterButton.anchor(top: stackView.bottomAnchor,
                           leading: contentView.leadingAnchor,
                           topConstant: 2, leadingConstant: 12)
        postCaptionTextView.anchor(top: likeCounterButton.bottomAnchor,
                                leading: contentView.leadingAnchor,
                                bottom: timeAgoLabel.topAnchor,
                                trailing: contentView.trailingAnchor,
                                leadingConstant: 12, bottomConstant: -8, TrailingConstant: -12)
        
        
        timeAgoLabel.anchor(leading: contentView.leadingAnchor,
                            bottom: contentView.bottomAnchor,
                            leadingConstant: 12, bottomConstant: -30)
        
    }
    
    func configure(with post: PostViewModel) {
        
        self.post_id = post.post_id
        self.post_user_uuid = post.post_user_uuid
        userNameLabel.text = post.poster_name
        userProfileView.sd_setImage(with: URL(string: post.user_image_url))
        userPostImageView.sd_setImage(with: URL(string: post.post_image_url))
        likeCount = post.total_like
        postCaptionTextView.attributedText = post.formatedCaption
        postCaptionTextView.textContainer.maximumNumberOfLines = post.isCaptionExpanded == true ? 0 : 2
        timeAgoLabel.text = post.timeAgo
        isLike = post.user_islike
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
