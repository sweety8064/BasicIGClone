//
//  ListViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/07/2023.
//

import UIKit
import XLPagerTabStrip

class ListViewController: UIViewController {
    
    
    weak var dataSource: GridListViewControllerDataSource?
    var viewModels: [PostViewModel] { // for manipulate data
        return dataSource!.fetchViewModelsProfilePost()
    }
    var sessionUser: InstagramUser? {
        return SessionManager.shared.getUser()
    }
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.createLayoutSection(section: sectionIndex)
        }
    )
    
    private func createLayoutSection(section: Int) -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(600)))

        
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(600)),
            subitems: [item]
        )
        
        
        let section = NSCollectionLayoutSection(group: group)
        return section

    }

    private func configureCollectionView() {
        collectionView.isScrollEnabled = false
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 671 - 44)
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dataSource?.didFinishConfigCV()
    }
    


}

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        
        cell.userPostImageView.sd_setImage(with: URL(string: viewModels[indexPath.row].post_image_url))
        cell.userProfileView.sd_setImage(with: URL(string: viewModels[indexPath.row].user_image_url))
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
}
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ListViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        let image = UIImage(named: "list")?.withRenderingMode(.alwaysTemplate) // enable tint color

        return IndicatorInfo(image: image)
    }
}

extension ListViewController: PostCollectionViewCellDelegate {
    func didTapShowMore(for cell: PostCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { // get indexpath of return cell
            print("cannot get indexPath!")
            return
        }
        
        viewModels[indexPath.row].isCaptionExpanded = true

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        
        dataSource?.didFinishConfigCV()
    }
    
    func didTapOptionMenuButton(post_id: Int, post_user_uuid: String) {
        guard let sessionUser = sessionUser else { fatalError() }
        
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { [weak self] action in
            
            let json = [
                "post_id": post_id
            ]
            
            APICaller.shared.deletePost(with: json) { [weak self] error in
                DispatchQueue.main.async {
                    self?.dataSource?.fetchProfilePost()
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        
        let alert = UIAlertController()
        
        if sessionUser.user_uuid == post_user_uuid { // enable delete option if owner
            alert.addAction(deletePostAction)
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    func didTapCommentButton(post_id: Int?) {
        
        let vc = CommentViewController()
        vc.post_id = post_id
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
        

    }
    
    func didTapLikeButton(for cell: PostCollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { // get indexpath of return cell
            print("cannot get indexPath!")
            return
        }
        
        guard let currentIGUser = sessionUser else {
            print("current user is nil!")
            return
        }
        

        //===================== update UI to prevent wrong value when scroll =================
        viewModels[indexPath.row].user_islike = cell.isLike
        viewModels[indexPath.row].total_like = cell.likeCount
        //self.collectionView?.reloadItems(at: [indexPath])
        //====================================================================================
        
        let json: [String: Any] = [
            "likePostUID": viewModels[indexPath.row].post_id,
            "userUID": currentIGUser.user_uuid,
            "createDate": Date().getFormattedTime()
        ]
        
        APICaller.shared.addLike(with: json) { success in
            
        }
    }
    
    func didTapLikeCounterButton(post_id: Int) {
        
        let followersListVC = FollowersListViewController(navigationBarTitle: "Likes")
        followersListVC.currentContainerHeight = 500
        followersListVC.post_id = post_id
        followersListVC.viewType = .like
        followersListVC.modalPresentationStyle = .overFullScreen
        present(followersListVC, animated: false)
        
    }
}
