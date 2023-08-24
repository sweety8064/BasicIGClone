//
//  Extensions.swift
//  Instagram Clone
//
//  Created by Sweety on 12/05/2023.
//
import UIKit
import Foundation

extension UIColor {
    
    static var mainBlue = UIColor.rgb(red: 17, green: 154, blue: 237)
    static var lightBlue = UIColor.rgb(red: 149, green: 204, blue: 244)
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255,
                       green: green/255,
                       blue: blue/255,
                       alpha: 1)
    }
    
    static func randomColor() -> UIColor {
        return rgb(red: CGFloat(Int.random(in: 1...255)),
                   green: CGFloat(Int.random(in: 1...255)),
                   blue: CGFloat(Int.random(in: 1...255)))
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

struct Debug {
    static var number = 0
    
    static func increment() {
        number += 1
        print("debug: \(number)")
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                topConstant: CGFloat = 0,
                leadingConstant: CGFloat = 0,
                bottomConstant: CGFloat = 0,
                TrailingConstant: CGFloat = 0,
                width: CGFloat = 0,
                height: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: leadingConstant).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: TrailingConstant).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func addLine(y: CGFloat) {
        let lineView = UIView()
        lineView.backgroundColor = .green
        addSubview(lineView)
        lineView.frame = CGRect(x: 0, y: y, width: 393, height: 3)
    }
}

extension Date {
    
    func timeAgoDisplay() {
        let internvalDiff = Date().timeIntervalSince(self)
        
        print("time ago: \(internvalDiff)")
    }
    
    func getFormattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"

        return dateFormatter.string(from: self)
    }
}

extension UIRefreshControl {
    func refreshManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height),
                                        animated: true)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}



