//
//  ListViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 17/07/2023.
//

import UIKit
import XLPagerTabStrip

protocol ListViewControllerDataSource: AnyObject {
    func initProfilePost(completion: @escaping () -> Void)
    
    func fetchProfilePost() -> [Post]
}

class ListViewController: UIViewController {
    
    
    
    weak var dataSource: GridListViewControllerDataSource?
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.createLayoutSection(section: sectionIndex)
        }
    )
    
    private func createLayoutSection(section: Int) -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(600)), subitems: [item])
        
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
    


}

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }

        
        if let dataSource = dataSource {
            cell.configure(with: dataSource.fetchProfilePost()[indexPath.row])
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.fetchProfilePost().count ?? 0
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
