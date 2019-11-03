//
//  DisplayDate.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

// Handles properties and methods related to changing the week on the time table.

import Foundation

class DisplayDate {
    
    // MARK: - Properties
    
    // Currently displaying on the time table
    private var displayDate = Date()
    var year: Int { calendar.component(.year, from: displayDate) }
    var month: Int { calendar.component(.month, from: displayDate) }
    var dayNumbers: [Int] = [0, 0, 0, 0, 0]
    
    // ISO8601 starts on Monday
    private let calendar = Calendar(identifier: .iso8601)
    private let oneDay: TimeInterval = 60 * 60 * 24
    private let oneWeek: TimeInterval = 60 * 60 * 24 * 7
    
    
    // MARK: - Methods
    
    init() {
        updateDayNumbers()
    }
    
    func changeWeek(by offset: Int) {
        let interval = oneWeek * Double(offset)
        displayDate = Date(timeInterval: interval, since: displayDate)
        updateDayNumbers()
    }
    
    private func updateDayNumbers() {
        // Start of the week for the displayed date
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: displayDate)
        var dayDate = calendar.date(from: components)!
        
        // Assign day numbers
        for day in dayNumbers.indices {
            dayNumbers[day] = calendar.component(.day, from: dayDate)
            dayDate = Date(timeInterval: oneDay, since: dayDate)
        }
    }
    
    /// Checks whether some day is today.
    /// - Parameter dayOfMonth: The day number of the month.
    func isToday(_ dayOfMonth: Int) -> Bool {
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        
        if today.year == year,
            today.month == month,
            today.day == dayOfMonth {
            return true
        } else {
            return false
        }
    }
}
