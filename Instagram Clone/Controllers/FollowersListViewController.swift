//
//  FollowersListViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 23/08/2023.
//

import SDWebImage
import Foundation
import UIKit

class FollowersListViewController: BottomSheetViewController {
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.createLayoutSection(section: sectionIndex)
        }
    )
    
    var currentIGUser: String?
    
    var users = [InstagramUserFollow]()
    var viewModels = [IGUserFollowViewModel]()
    
    enum Types {
        case follower, following, like
    }
    
    var viewType: Types?
    
    var sessionUserUID: String? {
        return SessionManager.shared.getUser()?.user_uuid
    }
    
    var post_id: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewType = viewType,
           let sessionUser = SessionManager.shared.getUser() {
            

            switch viewType {
            case .follower:
                guard let userUID = currentIGUser else { fatalError() }
                let json = [
                    "user_uuid": userUID,
                    "session_user_uuid": sessionUser.user_uuid
                ]
                APICaller.shared.fetchFollower(with: json) { [weak self] result in
                    switch result {
                    case .success(let users):
                        self?.users = users
                        self?.configureViewModels()
                        DispatchQueue.main.async {
                            self?.collectionView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .following:
                guard let userUID = currentIGUser else { fatalError() }
                let json = [
                    "user_uuid": userUID,
                    "session_user_uuid": sessionUser.user_uuid
                ]
                APICaller.shared.fetchFollowing(with: json) { [weak self] result in
                    switch result {
                    case .success(let users):
                        self?.users = users
                        self?.configureViewModels()
                        DispatchQueue.main.async {
                            self?.collectionView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .like:
                guard let post_id = post_id else { fatalError() }
                let json: [String: Any] = [
                    "session_user_uuid": sessionUser.user_uuid,
                    "post_id": post_id
                ]
                APICaller.shared.fetchUsersLikePost(with: json) { [weak self] result in
                    switch result {
                    case .success(let users):
                        self?.users = users
                        self?.configureViewModels()
                        DispatchQueue.main.async {
                            self?.collectionView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            
        }
        
        configureCollectionView()
    }
    
    func configureViewModels() {
        for user in users {
            viewModels.append(IGUserFollowViewModel(user_uuid: user.user_uuid,
                                                    name: user.name,
                                                    profile_image_url: user.profile_image_url,
                                                    is_following_back: user.is_following_back)
            )
        }
        
    }
    
    private func configureCollectionView() {
        collectionView.isScrollEnabled = false
        view.addSubview(collectionView)
        collectionView.anchor(top: grabberViewArea.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
        collectionView.register(IGUserListCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayoutSection(section: Int) -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(66)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section

    }
}

extension FollowersListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? IGUserListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.sessionUserUID = self.sessionUserUID
        cell.configure(with: viewModels[indexPath.row])
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
}
extension FollowersListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
