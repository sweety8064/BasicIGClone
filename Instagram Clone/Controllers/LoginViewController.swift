//
//  LoginViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 11/05/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let logoContainer: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        imageView.translatesAutoresizingMaskIntoConstraints = false    //must set to false to use constraint
        return imageView
    }()
    
    let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Instagram_logo_white") //#imageLiteral(
        imageView.contentMode = .scaleAspectFit         // default mode is scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
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
        textField.text = "jc@gmail.com"
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.keyboardType = .emailAddress
        textField.placeholder = "Password"
        textField.text = "123456Qw"
        textField.isSecureTextEntry = true
    
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightBlue
        button.layer.cornerRadius = 5     // slightly curve but not make it circle
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.isEnabled = false
        button.addTarget(self, action: #selector(loginButtonDidPress), for: .touchUpInside)
        return button
    }()
    
    lazy var messageOutContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var messageInContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    let message: UILabel = {
        let message = UILabel()
        message.text = "Don't have an account?"
        message.textColor = .lightGray
        message.font = UIFont.systemFont(ofSize: 14)
        message.sizeToFit()
        
        message.translatesAutoresizingMaskIntoConstraints = false
        return message
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.addTarget(self, action: #selector(signUpButtonDidPress), for: .touchUpInside)
        button.setTitle(" Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textColor = UIColor.mainBlue
        //button.titleLabel?.textAlignment = .center
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        //================ hide the navigatio bar =======================
        navigationController?.navigationBar.isHidden = true
        
        //================ when user tap on anywhere will dismiss keyboard =============
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnView)))
        
        view.addSubview(logoContainer)
        logoContainer.addSubview(logo)
        view.addSubview(stackView)
        view.addSubview(messageOutContainer)
        messageOutContainer.addSubview(messageInContainer)
        messageInContainer.addSubview(message)
        messageInContainer.addSubview(signUpButton)

        
        configureAutoLayout()
        
        
    }
    
    @objc private func handleTapOnView() { // tap on view will dismiss keyboard
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func signUpButtonDidPress() {
        let registerViewController = RegisterViewController()
        registerViewController.handle = { [weak self] email, password in
            // Handle the received data in the root view controller
            self?.emailTextField.text = email
            self?.passwordTextField.text = password
            self?.signIn()
        }
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @objc private func loginButtonDidPress() {
        self.signIn()
    }
    
    private func signIn() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("email or password field must contain text!")
            return
        }
        
        SessionManager.shared.signIn(withEmail: email, password: password) { [weak self] error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.presentAlert(title: "Error Occured", message: error!.localizedDescription)
                    return
                }
                self?.dismiss(animated: true) // this code trigger tabBarController's viewDidAppear func
            }
        }
        
    }
    
    func configureAutoLayout() {
        var allConstraints = [NSLayoutConstraint]()
        
        allConstraints += logoContainerConstraints()
        allConstraints += logoConstrains()
        allConstraints += stackViewConstrains()
        allConstraints += messageOutContainerConstrains()
        allConstraints += messageInContrainerConstraits()
        allConstraints += signUpButtonConstraints()

        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    private func presentAlert(title: String, message: String) {
        let cancelAction = UIAlertAction(title: "OK", style: .default) { action in }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    deinit {
        print("LoginVC deinit!")
    }
    
    //MARK: - Constraints
    
    func logoContainerConstraints() -> [NSLayoutConstraint] {
        let top = logoContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let leading = logoContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        let trailing = logoContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        let height = logoContainer.heightAnchor.constraint(equalToConstant: 184)
        
        let constraints = [top, leading, trailing, height]
        return constraints
    }
    
    func logoConstrains() -> [NSLayoutConstraint] {
        let height = logo.heightAnchor.constraint(equalToConstant: 80)
        let width = logo.widthAnchor.constraint(equalToConstant: 300)
        let centerX = logo.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor)
        let centerY = logo.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor)
        
        let constraints = [height, width, centerX, centerY]
        return constraints
    }
    
    func stackViewConstrains() -> [NSLayoutConstraint] {
        let top = stackView.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 40)
        let leading = stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40)
        let trailing = stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        let height = stackView.heightAnchor.constraint(equalToConstant: 140)
        
        let constraints = [top, leading, trailing, height]
        return constraints
    }
    
    func messageOutContainerConstrains() -> [NSLayoutConstraint] {
        let leading = messageOutContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        let trailing = messageOutContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        let bottom = messageOutContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let height = messageOutContainer.heightAnchor.constraint(equalToConstant: 50)
        
        let constraints = [leading, trailing, bottom, height]
        return constraints
    }
    
    func messageInContrainerConstraits() -> [NSLayoutConstraint] {
        let centerX = messageInContainer.centerXAnchor.constraint(equalTo: messageOutContainer.centerXAnchor)
        let centerY = messageInContainer.centerYAnchor.constraint(equalTo: messageOutContainer.centerYAnchor)
        let height = messageInContainer.heightAnchor.constraint(equalToConstant: message.frame.height)
        let width = messageInContainer.widthAnchor.constraint(equalToConstant: message.frame.width + signUpButton.frame.width)
        
        let constrains = [centerX, centerY, height, width]
        return constrains
    }
    
    func signUpButtonConstraints() -> [NSLayoutConstraint] {
        let leading = signUpButton.leadingAnchor.constraint(equalTo: message.trailingAnchor)
        let height = signUpButton.heightAnchor.constraint(equalToConstant: message.frame.height)
        
        let constrains = [leading, height]
        return constrains
    }

    func getStatusBarHeight() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let statusBarManager = windowScene.statusBarManager { // this is 'if let' not 'let'
            
            let statusBarHeight = statusBarManager.statusBarFrame.height
            return statusBarHeight
        } else {
            return 0
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    @objc private func inputFieldDidChange() {
        if let emailTfHasText = emailTextField.text?.isEmpty,
           let passwordTfHasText = passwordTextField.text?.isEmpty {
            
            if !emailTfHasText && !passwordTfHasText {
                loginButton.isEnabled = true
                loginButton.backgroundColor = .mainBlue
            } else {
                loginButton.isEnabled = false
                loginButton.backgroundColor = .lightBlue
            }
        }
    }
}
