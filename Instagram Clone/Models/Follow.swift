//
//  Follow.swift
//  Instagram Clone
//
//  Created by Sweety on 13/07/2023.
//

import Foundation

struct Follow: Codable {
    let follower_uuid: [String]
    let following_uuid: [String]
    let total_post: Int
}
