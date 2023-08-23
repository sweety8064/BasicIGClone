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
    
    var userUID: String?
    
    var users = [InstagramUser]()
    var viewModels = [InstagramUserViewModel]()
    
    enum Types {
        case follower, following
    }
    
    var viewType: Types?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userUID = userUID, let viewType = viewType {
            
            let json = [
                "user_uuid": userUID
            ]
            
            switch viewType {
            case .follower:
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
            }
            
            
        }
        
        configureCollectionView()
    }
    
    func configureViewModels() {
        for user in users {
            viewModels.append(InstagramUserViewModel(name: user.name,
                                                     profile_image_url: user.profile_image_url))
        }
        
    }
    
    private func configureCollectionView() {
        collectionView.isScrollEnabled = false
        view.addSubview(collectionView)
        collectionView.anchor(top: grabberViewArea.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SearchCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        cell.profileImageView.sd_setImage(with: URL(string: viewModels[indexPath.row].profile_image_url))
        
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
