//
//  Date+fromString.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

extension Date {
    
    /// Returns a `Date` object from a string formatted `YYYY-MM-DD`.
    ///
    /// Not immediately suitable for user-viewable spaces, as timezone is not taken into consideration.
    init(string dateString: String) {
        // Specify expected format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // If the format is wrong, just use the current date
        guard let date = dateFormatter.date(from: dateString) else { self.init(); return }
        
        self = date
    }
    
}
