//
//  User.swift
//  Instagram Clone
//
//  Created by Sweety on 29/06/2023.
//

import Foundation

struct InstagramUser: Codable {
    let user_uuid: String
    let name: String
    let create_date: String
    let email: String
    let profile_image_url: String
}
