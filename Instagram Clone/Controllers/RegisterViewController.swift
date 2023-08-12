//
//  RegisterViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 18/05/2023.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    var handle: ((String, String) -> Void)? //for pre-set textfield email, password and auto login
    var imagePicked: UIImage?
    
    let selectPhotoContainer: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let selectPhotoButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleToFill
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 140 / 2
        button.addTarget(self, action: #selector(didTapSelectPhotoButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField,
                                                       passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.keyboardType = .emailAddress
        textField.placeholder = "Email"
    
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.placeholder = "Username"
    
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.placeholder = "Password"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.sizeToFit()
        textField.isSecureTextEntry = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightBlue
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.sizeToFit()
        button.addTarget(self, action: #selector(signUpButtonDidPress), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let message: UILabel = {
        let message = UILabel()
        message.text = "Already have an account?"
        message.textColor = .lightGray
        message.font = UIFont.systemFont(ofSize: 14)
        message.sizeToFit()
        message.translatesAutoresizingMaskIntoConstraints = false
        return message
    }()
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.addTarget(self, action: #selector(signInButtonDidPress), for: .touchUpInside)
        button.setTitle(" Sign In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textColor = UIColor.mainBlue
        //button.titleLabel?.textAlignment = .center
        button.sizeToFit()    // let frame initlize value for layout calculation use
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(selectPhotoContainer)
        view.addSubview(selectPhotoButton)
        view.addSubview(stackView)
        view.addSubview(message)
        view.addSubview(signInButton)
        view.addSubview(signInButton)
        
        configureAutoLayout()
    }
    
    @objc private func signUpButtonDidPress() {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let username = usernameTextField.text,
              let imagePicked = imagePicked else {
            return
        }
        
        SessionManager.shared.signUp(withEmail: email,
                                     password: password,
                                     username: username,
                                     profileImage: imagePicked) { [weak self] success in
            
            if success {
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                    self?.handle?(email, password) //notify "registerViewController.handle" in LoginViewController
                    print("Successfully register!")
                }
                
            }
            
        }
        
    }
    
    deinit {
        print("RegisterViewController deinit!")
    }
    
    private func addUserToDatabase(with user: User) {
        
        guard let imagePicked = imagePicked else {
            print("imagePicked is nil!")
            return
        }
        
        let jsonUser: [String: Any] = [
            "uid": user.uid,
            "name": user.displayName!,
            "email": user.email!,
            "profilePic": imagePicked
        ]
        
        APICaller.shared.createUser(with: jsonUser) { success in
            if success {
                print("yes")
            } else {
                print("no")
            }
        }
    }
    
    @objc private func didTapSelectPhotoButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    @objc private func signInButtonDidPress() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func configureAutoLayout() {
        
        selectPhotoContainerConstrainsSetup()
        selectPhotoButtonConstraintsSetup()
        stackViewConstrainsSetup()
        messageConstrainsSetup()
        signInButtonConstrainsSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //MARK: - Constraints
    func selectPhotoContainerConstrainsSetup() {
        selectPhotoContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        selectPhotoContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        selectPhotoContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        selectPhotoContainer.heightAnchor.constraint(equalToConstant: 180).isActive = true
    }
    
    func selectPhotoButtonConstraintsSetup() {
        selectPhotoButton.centerXAnchor.constraint(equalTo: selectPhotoContainer.centerXAnchor).isActive = true
        selectPhotoButton.centerYAnchor.constraint(equalTo: selectPhotoContainer.centerYAnchor).isActive = true
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        selectPhotoButton.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
    }
    
    func stackViewConstrainsSetup() {
        stackView.topAnchor.constraint(equalTo: selectPhotoContainer.bottomAnchor, constant: 40).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func messageConstrainsSetup() {
        message.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        message.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: (view.frame.width - message.frame.width - signInButton.frame.width) / 2).isActive = true

        message.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func signInButtonConstrainsSetup() {
        signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: message.trailingAnchor).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    

}

extension RegisterViewController: UITextFieldDelegate {
    
    @objc private func inputFieldDidChange() {
        
        if let emailHasText = emailTextField.text?.isEmpty,
           let usernameHasText = usernameTextField.text?.isEmpty,
           let passwordHasText = passwordTextField.text?.isEmpty {
                
            if !emailHasText && !usernameHasText && !passwordHasText {
                signUpButton.backgroundColor = .mainBlue
                signUpButton.isEnabled = true
            } else {
                signUpButton.backgroundColor = .lightBlue
                signUpButton.isEnabled = false
            }
        }
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicked = info[.editedImage] as? UIImage
        
        selectPhotoButton.setImage(imagePicked, for: .normal)
        dismiss(animated: true)
    }
}

extension RegisterViewController: UINavigationControllerDelegate {
    
}
