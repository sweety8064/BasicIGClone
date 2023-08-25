//
//  SharePhotoViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 26/05/2023.
//

import UIKit
import FirebaseAuth

class SharePhotoViewController: UIViewController {
    
    let selectedPhoto: UIImage
    
    let container: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    let textField: PlaceHolderTextView = {
        let textView = PlaceHolderTextView()
        textView.backgroundColor = .white
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.autocorrectionType = .no
        textView.placeHolderLabel.text = "Add a caption..."
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var selectedPhotoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = selectedPhoto
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(selectedPhoto: UIImage) {
        self.selectedPhoto = selectedPhoto
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        view.addSubview(container)
        container.addSubview(textField)
        container.addSubview(selectedPhotoView)
        
        configureNavigationBar()
        configAutoLayout()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .plain,
            target: self,
            action: #selector(didTapNavigationPost))
    }
    
    @objc private func didTapNavigationPost() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("current username is nil!")
            return
        }
        
        guard let text = textField.text else {
            print("text is empty!")
            return
        }
        
        let json = [
            "uid": uid,
            "caption": text,
            "createDate": Date().getFormattedTime()
        ]
        
        APICaller.shared.createPost(withData: json, image: selectedPhoto) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    private func configAutoLayout() {
        containerConstraints()
        selectedPhotoViewConstraints()
        textFieldConstraints()
    }
    
    private func containerConstraints() {
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func selectedPhotoViewConstraints() {
        selectedPhotoView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8).isActive = true
        selectedPhotoView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8).isActive = true
        selectedPhotoView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8).isActive = true
        selectedPhotoView.widthAnchor.constraint(equalToConstant: 84).isActive = true
    }
    
    private func textFieldConstraints () {
        textField.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: selectedPhotoView.trailingAnchor, constant: 8).isActive = true
        textField.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    



}
