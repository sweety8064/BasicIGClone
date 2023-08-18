//
//  CommentViewModel.swift
//  Instagram Clone
//
//  Created by Sweety on 18/08/2023.
//

import Foundation
import UIKit

struct CommentViewModel {
    let user_id: String
    let content: String
    let create_date: String
    let user_name: String
    let user_image_url: String
    let create_date_utc0: String
    
    var formatedContent: NSAttributedString {
        return formatString(withUserUID: user_name, content: content)
    }
    
    var timeAgo: String? {
        return formatCommentDate()
    }
    
    private func formatString(withUserUID: String, content: String) -> NSAttributedString {
        let fullString = "\(withUserUID) \(content)"
        
        // ===================== user attribute and range =========================================
        let boldRangeUser = (fullString as NSString).range(of: withUserUID)
        let boldAttributesUser = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        
        // ===================== content attribute and range =========================================
        let boldRangeCaption = (fullString as NSString).range(of: content)
        let boldAttributesCaption = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
        
        // ============================================================================
        
        let attributedString = NSMutableAttributedString(string: fullString)
        attributedString.addAttributes(boldAttributesUser, range: boldRangeUser)
        attributedString.addAttributes(boldAttributesCaption, range: boldRangeCaption)
        
        return attributedString
        
        
    }
    
    private func formatCommentDate() -> String? {
        //======================= setting up date formatter ==========================
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        
        //============================================================================
        if let fPostCreatedDate: Date = dateFormatter.date(from: create_date_utc0) {
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
