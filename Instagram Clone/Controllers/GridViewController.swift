//
//  GridViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/07/2023.
//

import UIKit
import XLPagerTabStrip
import SDWebImage

protocol GridListViewControllerDataSource: AnyObject {
    
    func fetchViewModelsProfilePost() -> [PostViewModel]
    
    func didFinishConfigCV()
    
    func fetchProfilePost()
}

class GridViewController: UIViewController {
    
    weak var dataSource: GridListViewControllerDataSource?
       
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.createLayoutSection(section: sectionIndex)
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
    }
    
    var isFirstTimeInit = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeInit {
            view.layoutIfNeeded()
            dataSource?.didFinishConfigCV()
            isFirstTimeInit = false
        }
        
    }
    


    
    private func configureCollectionView() {
        collectionView.isScrollEnabled = false
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 671 - 44)
        // 671 is get from (full view - view.safeareatop - view.safeareabottom) and 44 (buttonBarViewHeight)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    


    private func createLayoutSection(section: Int) -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(CGFloat(1)/3),
                                               heightDimension: .fractionalHeight(1))
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(CGFloat(1)/3)),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)

        return section
    }
    

}

extension GridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let dataSource = dataSource,
           let postImageUrl = URL(string: dataSource.fetchViewModelsProfilePost()[indexPath.row].post_image_url) {
            cell.imageView.sd_setImage(with: postImageUrl)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.fetchViewModelsProfilePost().count ?? 0
    }
    
    
}

extension GridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    
    
}

extension GridViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        let image = UIImage(named: "grid")?.withRenderingMode(.alwaysTemplate) // enable tint color

        return IndicatorInfo(image: image)
    }
}
