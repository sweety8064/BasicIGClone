//
//  CommentInputAccessoryView.swift
//  Instagram Clone
//
//  Created by Sweety on 16/08/2023.
//

import UIKit

protocol CommentInputAccessoryViewDelegate: AnyObject {
    func didSubmit(comment: String)
}

class CommentTextView: UIView {
    
    weak var delegate: CommentInputAccessoryViewDelegate?
    
    let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let placeHolderTextView: PlaceHolderTextView = {
        let textView = PlaceHolderTextView()
        textView.placeHolderLabel.text = "Add a comment..."
        textView.isScrollEnabled = false // stuck very long
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.autocorrectionType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.lightGray, for: .normal)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override var intrinsicContentSize: CGSize { return .zero }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        addSubview(lineSeparatorView)
        addSubview(placeHolderTextView)
        addSubview(submitButton)
        
        configureAutoLayout()
    }
    
    private func configureAutoLayout() {
        
        lineSeparatorView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, height: 1)
        
        placeHolderTextView.anchor(top: lineSeparatorView.bottomAnchor,
                                   leading: leadingAnchor,
                                   bottom: layoutMarginsGuide.bottomAnchor,
                                   trailing: submitButton.leadingAnchor,
                                   topConstant: 8, leadingConstant: 12, bottomConstant: -8)
        
        submitButton.anchor(top: lineSeparatorView.bottomAnchor,
                            trailing: trailingAnchor,
                            TrailingConstant: -12,
                            width: 50, height: 50)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTextChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearCommentTextField() {
        placeHolderTextView.text = nil
        placeHolderTextView.placeHolderLabel.isHidden = false
        submitButton.isEnabled = false
        submitButton.setTitleColor(.lightGray, for: .normal)
    }
    
    @objc private func handleSubmit() {
        guard let commentText = placeHolderTextView.text else { return }
        placeHolderTextView.resignFirstResponder()
        delegate?.didSubmit(comment: commentText)
        clearCommentTextField()
    }
}

extension CommentTextView: UITextViewDelegate {
    
    @objc private func handleTextChange() {
        guard let text = placeHolderTextView.text else { return }
        
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            submitButton.isEnabled = false
            submitButton.setTitleColor(.lightGray, for: .normal)
        } else {
            submitButton.isEnabled = true
            submitButton.setTitleColor(.black, for: .normal)
        }
        
    }
}
