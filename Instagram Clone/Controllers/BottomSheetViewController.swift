//
//  BottomSheetViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 23/08/2023.
//  refer from https://betterprogramming.pub/how-to-present-a-bottom-sheet-view-controller-in-ios-a5a3e2047af9

import UIKit
import Foundation

class BottomSheetViewController: UIViewController {
    
    let grabberView: GrabberView = {
        let view = GrabberView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let defaultHeight: CGFloat = 500
    let dismissibleHeight: CGFloat = 400
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    let maxDimmedAlpha: CGFloat = 0.6

    var currentContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    var navigationBarTitle: String?
    
    let grabberViewArea: UIView = {
        let view = UIView()
        return view
    }()
    
    let separateLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return view
    }()
    
    init(navigationBarTitle: String) {
        self.navigationBarTitle = navigationBarTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(grabberViewArea)
        grabberViewArea.addSubview(grabberView)

        configureAutoLayout()
        if let navigationBarTitle = navigationBarTitle {
            setupNavBar()
        }
        setupTapGestureForClosing()
        setupPanGestureForHandleHeight()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
        
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    
    
    func configureAutoLayout() { // call by viewDidLoad
        // dimmedView
        dimmedView.anchor(top: view.topAnchor,
                          leading: view.leadingAnchor,
                          bottom: view.bottomAnchor,
                          trailing: view.trailingAnchor)
        
        //containerView
        containerView.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor)
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: currentContainerHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                              constant: defaultHeight)

        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
        
        // grabberViewArea
        grabberViewArea.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, height: 70)
        
        grabberView.anchor(top: grabberViewArea.topAnchor,
                           leading: grabberViewArea.leadingAnchor,
                           trailing: grabberViewArea.trailingAnchor)
        
        
    }
    
    private func setupNavBar() {
        
        let navTitle = UINavigationItem(title: navigationBarTitle!)
        
        let navigationBar = UINavigationBar()
        navigationBar.items = [navTitle]
        navigationBar.barTintColor = .white
        
        grabberViewArea.addSubview(navigationBar)
        navigationBar.anchor(top: grabberView.bottomAnchor,
                             leading: grabberViewArea.leadingAnchor,
                             trailing: grabberViewArea.trailingAnchor, topConstant: 5)
        
        
        
    }
    
    deinit {
        print("CustomModalViewController deinit!")
    }
}

//MARK: - BottomSheetViewController Logic
extension BottomSheetViewController {
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        let isDraggingDown = translation.y > 0

        let newHeight = currentContainerHeight - translation.y
        
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            
            // Condition 2: If new height is below default, animate back to default
            else if newHeight < defaultHeight { // defaultHeight = 300
                animateContainerHeight(defaultHeight)
            }
            // Condition 3: If new height is below max and going down, set to default height
            else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            // Condition 4: If new height is below max and going up, set to max height at top
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    

    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
    }
    
    func setupPanGestureForHandleHeight() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(self.handlePanGesture(gesture:))
        )
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func setupTapGestureForClosing() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
    }
}
