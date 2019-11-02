//
//  WeeklyCalendar.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

struct CalendarCourse {
    let course: Course
    // 5-minute intervals
    let startBlock: Int
    let endBlock: Int
    
    init(course: Course) {
        self.course = course
        startBlock = WeeklyCalendar.blocksFromTime(course.startTime)
        endBlock = WeeklyCalendar.blocksFromTime(course.endTime)
    }
}

typealias DaySchedule = [CalendarCourse]


/// Creates the calendar in the time table view.
class WeeklyCalendar {
    
    // MARK: - Properties
    
    private let dayStacks: [UIStackView]
    
    private var mondaySchedule: DaySchedule = []
    private var tuesdaySchedule: DaySchedule = []
    private var wednesdaySchedule: DaySchedule = []
    private var thursdaySchedule: DaySchedule = []
    private var fridaySchedule: DaySchedule = []
    
    private var schedules: [DaySchedule] = []
    
    // 18 30-minute blocks, plus two blocks for weekday + day number
    private let rowsPerDay = 20
    // 5-minute intervals
    private var blocksPerDay: Int { 30 / 5 * rowsPerDay }
    
    
    // MARK: - Methods
    
    init(dayStacks: [UIStackView]) {
        self.dayStacks = dayStacks
        schedules = [
            mondaySchedule,
            tuesdaySchedule,
            wednesdaySchedule,
            thursdaySchedule,
            fridaySchedule
        ]
    }
    
    /// Calculates the vertical position on the calendar for a given time.
    static func blocksFromTime(_ time: String) -> Int {
        let components = time.split(separator: ":")
        let hour = Int(components.first!)
        let minute = Int(components.last!)
        
        // TODO: This should be 9, after accounting for day header
        let startHour = 8
        let hourBlocks = (hour! - startHour) * 12
        var minuteBlocks = 0
        if minute! > 0 { minuteBlocks = minute! / 5 }
        
        return hourBlocks + minuteBlocks
    }
    
    private func blocksFromTime(_ time: String) -> Int {
        WeeklyCalendar.blocksFromTime(time)
    }
    
    /// Sets up all five day views in the calendar.
    func reloadWeek(courses: Courses, timeTable: TimeTable) {
        // Group time table courses by day
        for code in timeTable.courseCodes {
            // Get course from full list
            guard let course = courses.results.first(where: { $0.code == code }) else { continue }
            // Add course to matching days
            appendCourse(course)
        }
        
        for day in schedules.indices {
            makeDaySchedule(for: day)
        }
    }
    
    
    /// Sets up a single day or set of days.
    func addCourse(_ course: Course) {
        appendCourse(course)
        for day in course.dayNumbers {
            makeDaySchedule(for: day)
        }
    }
    
    private func appendCourse(_ course: Course) {
        for day in course.dayNumbers {
            let calendarCourse = CalendarCourse(course: course)
            schedules[day].append(calendarCourse)
        }
    }
    
    /// Removes a course from the calendar when the user has unregistered.
    func removeCourse(_ course: Course) {
        for day in course.dayNumbers {
            schedules[day].removeAll { $0.course.code == course.code }
            makeDaySchedule(for: day)
        }
    }
    
    /// Updates a course when it has had a change of memos.
    func updateCourse(_ course: Course) {
        for day in course.dayNumbers {
            guard let index = schedules[day].firstIndex(where: { $0.course.code == course.code }) else { return }
            schedules[day][index] = CalendarCourse(course: course)
            makeDaySchedule(for: day)
        }
    }
    
    /// Makes a visual representation of one day of the user's time table.
    private func makeDaySchedule(for day: Int) {
        // Arrange courses as startBlock:endBlock
        var courses: [Int: Int] = [:]
        for course in schedules[day] {
            courses[course.startBlock] = course.endBlock
        }
        
        let stackView = dayStacks[day]
        updateDayStack(stackView, courses: courses)
    }
    
    /// Updates one day stack with all the subviews representing that day's schedule.
    private func updateDayStack(_ stackView: UIStackView, courses: [Int: Int]) {
        // Add empty times into schedule
        let schedule = makeDayBlocks(courses)
        
        // We will active all height constraints simultaneously
        var constraints: [NSLayoutConstraint] = []
        
        var grey: CGFloat = 0.0
        
        // Go through each item, in order, and add them to the stack
        for calendarItem in schedule.sorted(by: { $0.key < $1.key }) {
            let calendarItemView = UIView()
                grey += 0.05
                let color = UIColor(white: grey, alpha: 1)
            calendarItemView.backgroundColor = color
            stackView.addArrangedSubview(calendarItemView)
            
            // Get height of view based on how long the time period is
            let blocks = calendarItem.value - calendarItem.key
            let height = CGFloat(Float(blocks) / Float(blocksPerDay))
            
            // Set height constraint, but not on last cell, to avoid math errors
            if calendarItem.value < blocksPerDay {
                // Constant accounts for size of stack spacing (row border)
                constraints.append(calendarItemView.heightAnchor.constraint(equalTo: calendarItemView.superview!.heightAnchor, multiplier: height, constant: -1))
            }
        }

//        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // FIXME: We probably need to erase previous blocks when updating (e.g. adding a course)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Creates all rectangular calendar entries, including empty spaces, for one day.
    private func makeDayBlocks(_ courses: [Int: Int]) -> [Int: Int] {
        // Classes from 9:00 ~
        // TODO: Should be 9:00
        let startOfDay = blocksFromTime("8:00")
        var start = startOfDay
        let endOfDay = blocksFromTime("18:00")
        
        // Set grid line times (fixed 30-minute intervals)
        // TODO: Make this a global constant, essentially
        var grid: [Int] = []
        for start in (start + 1)...endOfDay {
            // 30min / 5min = 6
            if start % 6 == 0 {
                grid.append(start)
            }
        }
        
        // Set up schedule to first include all course times
        var schedule: [Int: Int] = courses
        
        // Empty block placeholder
        var emptyBlock = 0
        
        // Check each five-minute interval for course or empty time
        while start <= endOfDay {
            // Add empty time where there is no course scheduled
            if let endOfCourse = courses[start] {
                // End empty block here, as long as it isn't the start of the day
                if start != startOfDay {
                    schedule[emptyBlock] = start
                    emptyBlock = start
                }
                // Go to end of this course block
                start = endOfCourse
            } else if grid.contains(start) && emptyBlock != start {
                // End empty block and begin new one
                schedule[emptyBlock] = start
                emptyBlock = start
                start += 1
            } else {
                // If we were already in an empty block and found no course, just check the next block
                start += 1
            }
        }
        
        return schedule
    }
    
}
