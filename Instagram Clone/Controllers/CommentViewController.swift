//
//  CustomModalViewController.swift
//  HalfScreenPresentation
//
//  Created by Hafiz on 06/06/2021.
//

import UIKit

class CommentViewController: UIViewController {
    
    var post_id: Int?
    
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
    
    
    lazy var collectionView = UICollectionView( //UICollectionViewCompositionalLayout(selectionProvider
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.createLayoutSection(section: sectionIndex)
        }
    )
    
    let grabberViewArea: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var commentTextView: CommentTextView = {
        let view = CommentTextView()
        return view
    }()
    
    override var canBecomeFirstResponder: Bool { return true }
    
    override var inputAccessoryView: UIView? { return commentTextView }
    
    var comments = [Comment]()
    var viewModels = [CommentViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(grabberViewArea)
        grabberViewArea.addSubview(grabberView)

        
        
        configureAutoLayout()
        setupNavBar()
        setupTapGestureForClosing()
        setupPanGestureForHandleHeight()
        
        
        
        fetchComment()
    }
    
    private func fetchComment() {
        if let post_id = self.post_id {
            let json = [
                "post_id": post_id
            ]
            
            APICaller.shared.fetchComment(with: json) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.comments = model
                    DispatchQueue.main.async {
                        
                        self?.configureViewModels()
                        self?.configureCollectionView()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func configureViewModels() {
        for comment in comments {
            viewModels.append(CommentViewModel(user_id: comment.user_id,
                                               content: comment.content,
                                               create_date: comment.create_date,
                                               user_name: comment.user_name,
                                               user_image_url: comment.user_image_url,
                                               create_date_utc0: comment.create_date_utc0)
            )
        }
    }
    
    private func setupNavBar() {
        
        let navTitle = UINavigationItem(title: "Comments")
        
        let navigationBar = UINavigationBar()
        navigationBar.items = [navTitle]
        navigationBar.barTintColor = .white
        
        grabberViewArea.addSubview(navigationBar)
        navigationBar.anchor(top: grabberView.bottomAnchor, leading: grabberViewArea.leadingAnchor , trailing: grabberViewArea.trailingAnchor, topConstant: 5)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.keyboardDismissMode = .interactiveWithAccessory
        
        containerView.addSubview(collectionView)
        collectionView.anchor(top: grabberViewArea.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
        
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder() // important
        self.commentTextView.placeHolderTextView.becomeFirstResponder()
        animatePresentContainer()
        
    }
    
    private func setupTapGestureForClosing() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    private func createLayoutSection(section: Int) -> NSCollectionLayoutSection {
        let section1: NSCollectionLayoutSection = {
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .estimated(30))
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .estimated(30)),
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }()
        
        return section1
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
        grabberViewArea.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, height: 69)
        
        grabberView.anchor(top: grabberViewArea.topAnchor,
                           leading: grabberViewArea.leadingAnchor,
                           trailing: grabberViewArea.trailingAnchor)
        
        
        
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
                self.commentTextView.placeHolderTextView.resignFirstResponder()
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
                collectionView.isScrollEnabled = true
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
    
    deinit {
        print("CustomModalViewController deinit!")
    }
}

extension CommentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CommentCollectionViewCell else {
            print("cannot convert to CommentCollectionViewCell")
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
}

extension CommentViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            //collectionView.isScrollEnabled = false
        }
    }
}

extension CommentViewController: CommentInputAccessoryViewDelegate {
    func didSubmit(comment: String) {
        if let post_id = self.post_id, let userUID = SessionManager.shared.getUser()?.user_uuid {
            
            let json: [String: Any] = [
                "post_id": post_id,
                "comment_text": comment,
                "user_id": userUID,
                "comment_date": Date().getFormattedTime()
            ]
            
            APICaller.shared.addComment(with: json) { error in
                guard error == nil else { return }
                
            }
        }
        
    }
}
