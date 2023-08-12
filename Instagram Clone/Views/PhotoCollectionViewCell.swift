//
//  PhotoCollectionViewCell.swift
//  Instagram Clone
//
//  Created by Sweety on 23/05/2023.
//

import UIKit
     
class PhotoCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
    }
    
    func configure(image: UIImage) {
        imageView.image = image
    }
}
