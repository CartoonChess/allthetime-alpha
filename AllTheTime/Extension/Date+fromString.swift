//
//  Date+fromString.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

extension Date {
    
    enum Format: String {
        case memo = "yyyy-MM-dd"
    }
    
    var string: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Format.memo.rawValue
        return formatter.string(from: self)
    }
    
    /// Returns a `Date` object from a string formatted `YYYY-MM-DD`.
    ///
    /// Not immediately suitable for user-viewable spaces, as timezone is not taken into consideration.
    init(string dateString: String) {
        // Specify expected format
        let formatter = DateFormatter()
        formatter.dateFormat = Format.memo.rawValue
        
        // If the format is wrong, just use the current date
        guard let date = formatter.date(from: dateString) else { self.init(); return }
        
        self = date
    }
    
}
