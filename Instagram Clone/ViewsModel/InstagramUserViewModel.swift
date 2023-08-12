//
//  InstagramUserViewModel.swift
//  Instagram Clone
//
//  Created by Sweety on 04/07/2023.
//

import Foundation
import UIKit

class InstagramUserViewModel {
    let name: String
    let profile_image_url: String
    var profileImage: UIImage?
    
    var profileImageIsAvailble: ((UIImage?) -> Void)?
    
    init(name: String, profile_image_url: String) {
        self.name = name
        self.profile_image_url = profile_image_url
        
        APICaller.shared.fetchImage(fromUrl: profile_image_url) { [weak self] result in
            switch result {
            case .success(let image):
                self?.profileImage = image
                self?.profileImageIsAvailble?(self?.profileImage)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    
}
