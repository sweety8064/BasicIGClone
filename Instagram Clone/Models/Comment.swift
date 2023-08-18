//
//  Comment.swift
//  Instagram Clone
//
//  Created by Sweety on 18/08/2023.
//

import Foundation

struct Comment: Codable {
    let post_id: Int
    let user_id: String
    let content: String
    let create_date: String
    let user_name: String
    let user_image_url: String
    let create_date_utc0: String
}
