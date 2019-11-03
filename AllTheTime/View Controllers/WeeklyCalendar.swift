//
//  WeeklyCalendar.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

struct CalendarBlock {
    // 5-minute intervals
    let startBlock: Int
    let endBlock: Int
    // Empty blocks won't have an associated course
    let course: Course?
    
    
    /// Creates a calendar block with an associated course.
    init(course: Course) {
        self.course = course
        startBlock = WeeklyCalendar.blocksFromTime(course.startTime)
        endBlock = WeeklyCalendar.blocksFromTime(course.endTime)
    }
    
    /// Creates an empty calendar block.
    init(startBlock: Int, endBlock: Int) {
        self.startBlock = startBlock
        self.endBlock = endBlock
        self.course = nil
    }
}

typealias DaySchedule = [CalendarBlock]


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
            updateDay(day)
        }
    }
    
    /// Sets up a single day or set of days.
    func addCourse(_ course: Course) {
        appendCourse(course)
        for day in course.dayNumbers {
            updateDay(day)
        }
    }
    
    private func appendCourse(_ course: Course) {
        for day in course.dayNumbers {
            let calendarCourse = CalendarBlock(course: course)
            schedules[day].append(calendarCourse)
        }
    }
    
    /// Removes a course from the calendar when the user has unregistered.
    func removeCourse(_ course: Course) {
        for day in course.dayNumbers {
            schedules[day].removeAll { $0.course?.code == course.code }
            updateDay(day)
        }
    }
    
    /// Updates a course when it has had a change of memos.
    func updateCourse(_ course: Course) {
        for day in course.dayNumbers {
            guard let index = schedules[day].firstIndex(where: { $0.course?.code == course.code }) else { return }
            schedules[day][index] = CalendarBlock(course: course)
            updateDay(day)
        }
    }
    
    /// Creates all rectangular calendar entries, including empty spaces, for one day.
    private func makeBlocksForDay(_ day: Int) -> DaySchedule {
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
        var emptyBlocks: [Int: Int] = [:]
        var courseBlocks: [Int: Int] = [:]
        for course in schedules[day] {
            courseBlocks[course.startBlock] = course.endBlock
        }

        // Empty block placeholder
        var emptyBlock = 0

        // Check each five-minute interval for course or empty time
        while start <= endOfDay {
            // Add empty time where there is no course scheduled
            if let endOfCourse = courseBlocks[start] {
                // End empty block here, as long as it isn't the start of the day
                if start != startOfDay {
                    emptyBlocks[emptyBlock] = start
                    // Note: Use `start` instead of `endOfCourse` to create blocks for ALL items, including courses
                    // This will double up when the two arrays are combined
                    // However, if can be useful if we change the implementation
                    // Also note: `endOfCourse` will not work if two courses overlap
                    // Using `start` and not combining arrays will simply use one course and ignore the other
                    emptyBlock = endOfCourse
                }
                // Go to end of this course block
                start = endOfCourse
            } else if grid.contains(start) && emptyBlock != start {
                // End empty block and begin new one
                emptyBlocks[emptyBlock] = start
                emptyBlock = start
                start += 1
            } else {
                // If we were already in an empty block and found no course, just check the next block
                start += 1
            }
        }

        // Create new schedule with courses and empty blocks
        var scheduleWithEmptyBlocks: DaySchedule = schedules[day]
        // Convert empty block dictionary to objects
        for (start, end) in emptyBlocks {
            let block = CalendarBlock(startBlock: start, endBlock: end)
            scheduleWithEmptyBlocks.append(block)
        }
        
        return scheduleWithEmptyBlocks
    }
    
    /// Updates one day stack with all the subviews representing that day's schedule.
    private func updateDay(_ day: Int) {
        // Add empty times into schedule
        let schedule = makeBlocksForDay(day)
        
        let stackView = dayStacks[day]
        
        // We will active all height constraints simultaneously
        var constraints: [NSLayoutConstraint] = []
        
//        var grey: CGFloat = 0.0
        
        // Go through each item, in order, and add them to the stack
        for block in schedule.sorted(by: { $0.startBlock < $1.startBlock }) {
            let calendarItemView = createView(for: block)
            stackView.addArrangedSubview(calendarItemView)
            
            // Get height of view based on how long the time period is
            let blocks = block.endBlock - block.startBlock
            let height = CGFloat(Float(blocks) / Float(blocksPerDay))
            
            // Set height constraint, but not on last cell, to avoid math errors
            if block.endBlock < blocksPerDay {
                // Constant accounts for size of stack spacing (row border)
                constraints.append(calendarItemView.heightAnchor.constraint(equalTo: calendarItemView.superview!.heightAnchor, multiplier: height, constant: -1))
            }
        }

//        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // FIXME: We probably need to erase previous blocks when updating (e.g. adding a course)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Creates the UIView for a calendar block.
    private func createView(for block: CalendarBlock) -> UIView {
        // Empty views need only their bg colour
        guard block.course != nil else {
            let view = UIView()
            view.backgroundColor = .systemAppearanceBackground
            return view
        }
        
        let viewModel = CalendarBlockCourseViewModel(block)
        let view = CalendarBlockView()
        view.viewModel = viewModel
        
        return view
    }
    
}
