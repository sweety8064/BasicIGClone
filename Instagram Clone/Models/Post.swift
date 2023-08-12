//
//  Post.swift
//  Instagram Clone
//
//  Created by Sweety on 05/06/2023.
//

import Foundation

struct Post: Codable {
    let post_id: Int
    let post_user_uuid: String
    let post_date: String
    let image_url: String
    let user_image_url: String
    let caption: String
    let post_username: String
    let post_date_utc0: String
    let total_like: Int
    let user_islike: Bool
}
