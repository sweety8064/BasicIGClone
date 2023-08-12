//
//  HeaderCollectionViewCell.swift
//  Instagram Clone
//
//  Created by Sweety on 23/05/2023.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {
    
    let headerView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        headerView.frame = contentView.bounds
    }
    
    func configure(image: UIImage?) {
        headerView.image = image
    }
}
