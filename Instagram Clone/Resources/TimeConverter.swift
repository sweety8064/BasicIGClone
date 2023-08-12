//
//  TimeConverter.swift
//  Instagram Clone
//
//  Created by Sweety on 13/06/2023.
//

import Foundation

struct TimeConverter {
    
    public static func timeAgoDisplay(second: Int) -> String {
        
        let minute = second / 60
        let hour = minute / 60
        let day = hour / 24
        let week = day / 7
        
        switch second {
        case 0...59:
            return "\(second) seconds"
        case 60...3599:
            return "\(minute) minutes"
        case 3600...86399:
            return "\(hour) hours"
        case 86400...604799:
            return "\(day) days"
        case 604800...4233599:
            return "\(week) weeks"
        default:
            return "asdasd"
        }
        
        
    }
}
