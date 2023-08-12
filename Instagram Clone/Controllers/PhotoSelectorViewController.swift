//
//  PhotoSelectorViewController.swift
//  Instagram Clone
//
//  Created by Sweety on 22/05/2023.
//

import UIKit
import Photos

class PhotoSelectorViewController: UIViewController {
    
    private var selectedImage: UIImage?
    private var allPhoto = [UIImage]()
    private var allAsset = [PHAsset]()
    
    var currentRequestIDKey: Int?
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
        return self?.createLayoutSection(section: sectionIndex)
    })
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureNavigationBar()
        fetchLocalPhotos()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapNavigationBarCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapNavigationBarNext))
    }
    
    @objc private func didTapNavigationBarCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapNavigationBarNext() {
        guard let selectedImage = selectedImage else {
            print("photo not selected!")
            return
        }
        let vc = SharePhotoViewController(selectedPhoto: selectedImage)
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView.register(HeaderCollectionViewCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "headerCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createLayoutSection(section: Int) -> NSCollectionLayoutSection {
        
        let section1: NSCollectionLayoutSection = {
            //=================== item  ============================
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4),
                                                   heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            
            //=================== group  ============================
            let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalHeight(1/8)),
                        subitems: [item]
                        )
            
            //=================== section  ============================
            let section = NSCollectionLayoutSection(group: group)
            
            //=================== add headerView ============================
            let supplementaryViews = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(view.frame.width),
                                                   heightDimension: .absolute(view.frame.width)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            supplementaryViews.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            section.boundarySupplementaryItems = [supplementaryViews]
            //================================================================
            
            return section
        }()
        
        return section1
    }
    
    func fetchLocalPhotos() {

        //==================== init fetchOptions ===================
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //=========================================================
        let fetchPhotoResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        for i in 0..<fetchPhotoResult.count {
            let asset = fetchPhotoResult.object(at: i)
            let options = PHImageRequestOptions()
            options.isSynchronous = true // to prevent duplicate photo
            
            // Request the image representation for the asset
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: 200, height: 200),
                                                  contentMode: .aspectFit,
                                                  options: options) { [weak self] image, info in
                if let image = image {
                    self?.allPhoto.append(image)
                    self?.allAsset.append(fetchPhotoResult[i])
                    if self?.selectedImage == nil {   // render first photo for header
                        self?.selectedImage = image
                    }
                }
                
                
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    

}

extension PhotoSelectorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = allPhoto[indexPath.row]
        collectionView.reloadData()
        
    }
}

extension PhotoSelectorViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhoto.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(image: allPhoto[indexPath.row])
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerCell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as? HeaderCollectionViewCell else { return UICollectionViewCell() }
        
        let index = allPhoto.firstIndex(of: selectedImage!)!
        let selectedAsset = allAsset[index]
    
        PHImageManager.default().requestImage(for: selectedAsset,
                                              targetSize: CGSize(width: 600, height: 600), //metal api validation
                                              contentMode: .default,
                                              options: nil) { [weak self] image, info in
            DispatchQueue.main.async { // prevent preview image replace when select too fast
                
                let isLowQualityImage = (info!["PHImageResultIsDegradedKey"] as! Int) == 1
                let requestIDKey = info!["PHImageResultRequestIDKey"] as! Int
                
                if isLowQualityImage {
                    self?.currentRequestIDKey = info!["PHImageResultRequestIDKey"] as? Int
                }
                
                if requestIDKey != self?.currentRequestIDKey { return }
                headerCell.configure(image: image)
                self?.selectedImage = image
            }
        }
        
        headerCell.configure(image: selectedImage)
        return headerCell
    }
    
    
    
    
}

