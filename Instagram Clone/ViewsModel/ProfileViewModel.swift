//
//  ProfileViewModel.swift
//  Instagram Clone
//
//  Created by Sweety on 05/07/2023.
//

import Foundation
import UIKit

class ProfileViewModel {
    
    let profile_image_url: String
    var profileImage: UIImage?
    let postsCount: Int
    let followersCount: Int
    let followingCount: Int
    let name: String
    

    
    var profileImageIsAvailble: ((UIImage?) -> Void)?
    
    init(profile_image_url: String, postsCount: Int, followersCount: Int, followingCount: Int, name: String) {
        self.profile_image_url = profile_image_url
        self.postsCount = postsCount
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.name = name
        
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
