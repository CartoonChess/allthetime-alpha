//
//  UIColor+systemAppearanceBackground.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var systemAppearanceBackground: UIColor {
        get {
            if #available(iOS 13, *) {
                return .systemBackground
            } else {
                return .white
            }
        }
    }
    
    // API doesn't currently assign colors to courses, so provide a consistent one
    static func calendarBlock(_ block: CalendarBlock) -> UIColor {
        // Get course's final code numbers, or return standard bg color
        guard let course = block.course,
            let code = Float(course.code.split(separator: "-").last!),
            code > 0 else {
            return .systemAppearanceBackground
        }
        
        // Room numbers currently range 101~620
        let nonNumberic = CharacterSet.decimalDigits.inverted
        let roomString: String = course.location.trimmingCharacters(in: nonNumberic)
        let room = Float((Float(roomString) ?? 101.0) - 100.0)
        
//        let red = CGFloat.random(in: 0.0...1.0)
        let red = CGFloat(code / 50.0)
        let green = CGFloat(Float(block.startBlock - 12) / 108.0)
        let blue = CGFloat(room / 519.0)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
}
