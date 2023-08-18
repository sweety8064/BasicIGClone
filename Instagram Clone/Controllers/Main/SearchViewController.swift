//
//  SearchViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/05/2023.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter username here"
        return searchBar
    }()
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.createLayoutSection(section: sectionIndex)
        }
    )
    
    var users = [InstagramUser]()
    var unfilteredUsers = [InstagramUser]() // for searching purpose use
    
    var viewModels = [InstagramUserViewModel]()
    var unfilteredUsersVM = [InstagramUserViewModel]() // for searching purpose use
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        navigationItem.titleView = searchBar      // add searchBarView at top
        
        configureCollectionView()
        fetchUser()
    }
    
    deinit {
        print("SearchVC deinit")
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              leading: view.leadingAnchor,
                              bottom: view.bottomAnchor,
                              trailing: view.trailingAnchor)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "searchCell")
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func fetchUser() {
        APICaller.shared.fetchUsers { [weak self] result in
            switch result {
            case .success(var users):
                // remove owner
                if let index = users.firstIndex(where: { $0.user_uuid == SessionManager.shared.getUser()?.user_uuid}) {
                    users.remove(at: index)
                }
                
                self?.users = users
                self?.configureViewModels()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
    func configureViewModels() {
        for user in users {
            viewModels.append(InstagramUserViewModel(name: user.name,
                                                     profile_image_url: user.profile_image_url))
        }
        
        unfilteredUsersVM = viewModels
        unfilteredUsers = users
    }
    
    func createLayoutSection(section: Int) -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(66)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    

}

//MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as? SearchCollectionViewCell
        else {
            print("cannot convert to SearchCollectionViewCell")
            return UICollectionViewCell()
        }
        
        let user = viewModels[indexPath.row]
        
        user.profileImageIsAvailble = { profileImage in
            DispatchQueue.main.async {
                cell.profileImageView.image = profileImage
            }
        }
        cell.configure(with: user)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        
        let profileVC = ProfileViewController()
        profileVC.configure(with: selectedUser)
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModels = unfilteredUsersVM
            users = unfilteredUsers
        } else {
            viewModels = viewModels.filter { (user) -> Bool in
                return user.name.lowercased().contains(searchText.lowercased())
            }
            users = users.filter { (user) -> Bool in
                return user.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()    // dismiss keyboard when tap search button
    }

}
