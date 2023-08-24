//
//  InstagramUserFollow.swift
//  Instagram Clone
//
//  Created by Sweety on 24/08/2023.
//

import Foundation

class InstagramUserFollow: Codable {
    let user_uuid: String
    let name: String
    let create_date: String
    let email: String
    let profile_image_url: String
    let is_following_back: Bool
}
