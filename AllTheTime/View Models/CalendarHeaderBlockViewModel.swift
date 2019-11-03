//
//  CalendarHeaderBlockViewModel.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

class CalendarHeaderBlockViewModel {
    let dayName: String
    let dayNumber: String
    var isToday: Bool = false
    
    init(dayName: String, dayNumber: Int, isToday: Bool) {
        self.dayName = dayName
        self.dayNumber = String(dayNumber)
        self.isToday = isToday
    }
}
