//
//  PostViewModel.swift
//  Instagram Clone
//
//  Created by Sweety on 08/06/2023.
//

import Foundation
import UIKit


class PostViewModel {
    let poster_name: String
    var post_image_url: String
    var user_image_url: String
    var total_like: Int
    let caption: String
    let post_date_utc0: String
    var postImage: UIImage?
    var userImage: UIImage?
    var user_islike: Bool
    
    var imageIsAvailable: ((UIImage?) -> Void)?
    var userImageIsAvailable: ((UIImage?) -> Void)?
    
    var formatedCaption: NSAttributedString {
        return formatCaption(withUser: poster_name, caption: caption)
    }
    
    var timeAgo: String? {
        return formatPostDate()
    }
    
    init(poster_name: String, post_image_url: String, user_image_url: String, total_like: Int, caption: String, post_date_utc0: String, user_islike: Bool) {
        self.poster_name = poster_name
        self.post_image_url = post_image_url
        self.user_image_url = user_image_url
        self.total_like = total_like
        self.caption = caption
        self.post_date_utc0 = post_date_utc0
        self.user_islike = user_islike
        
        APICaller.shared.fetchImage(fromUrl: user_image_url) { [weak self] result in // profile image
            switch result {
            case .success(let image):
                self?.userImage = image
                self?.userImageIsAvailable?(self?.userImage)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        APICaller.shared.fetchImage(fromUrl: post_image_url) { [weak self] result in // post image
            switch result {
            case .success(let image):
                self?.postImage = image
                self?.imageIsAvailable?(self?.postImage)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func formatCaption(withUser: String, caption: String) -> NSAttributedString {
        let text: String = "\(withUser) \(caption)"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        
        // ===================== user attribute and range =========================================
        let boldRangeUser = (text as NSString).range(of: withUser)
        let boldAttributesUser = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        
        // ===================== caption attribute and range =========================================
        let boldRangeCaption = (text as NSString).range(of: caption)
        let boldAttributesCaption = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
        
        // ============================================================================
        attributedString.addAttributes(boldAttributesUser, range: boldRangeUser)
        attributedString.addAttributes(boldAttributesCaption, range: boldRangeCaption)
        
        return attributedString
    }
    
    private func formatPostDate() -> String? {
        //======================= setting up date formatter ==========================
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        
        //============================================================================
        if let fPostCreatedDate: Date = dateFormatter.date(from: post_date_utc0) {
            
            let intervalDiff = Int(Date().timeIntervalSince(fPostCreatedDate))
            return timeAgoDisplay(second: intervalDiff)
        } else {
            print("Failed to parse timestamp")
            return nil
        }
    }
    
    private func timeAgoDisplay(second: Int) -> String {
        
        let minute = second / 60
        let hour = minute / 60
        let day = hour / 24
        let week = day / 7
        
        switch second {
        case 0...59:
            return "\(second) seconds ago"
        case 60...3599:
            return "\(minute) minutes ago"
        case 3600...86399:
            return "\(hour) hours ago"
        case 86400...604799:
            return "\(day) days ago"
        case 604800...4233599:
            return "\(week) weeks ago"
        default:
            return "a month ago..."
        }
        
        
    }
}
