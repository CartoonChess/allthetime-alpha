//
//  ViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/29.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class TimeTableViewController: UIViewController {
    
    // MARK: - Properties
    var courses: Courses?
    var timeTable: TimeTable?
    var memos: Memos?
    
    var days: [TimeTableDay] = []
    
    // 18 30-minute blocks, plus two blocks for weekday + day number
    let rowsPerDay = 20
    var blocksPerDay: Int {
        30 / 5 * rowsPerDay // 5-minute intervals
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var mondayStackView: UIStackView!
    @IBOutlet weak var tuesdayStackView: UIStackView!
    @IBOutlet weak var wednesdayStackView: UIStackView!
    @IBOutlet weak var thursdayStackView: UIStackView!
    @IBOutlet weak var fridayStackView: UIStackView!
    
    
    // MARK: - Methods
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Main view loaded.")
        
        // Disable search until after courses are loaded
        toggleSearch(enable: false)
        
        // Get all courses from API
        fetchData()
    }
    
    func fetchData() {
        let dataFetcher = APIDataFetcher()
        dataFetcher.fetchAll { result in
            switch result {
            case .success(let courses, let timeTable, let memos):
                self.courses = courses
                self.timeTable = timeTable
                self.memos = memos
                self.updateView()
            case .failure(let error):
                print("Failed to fetch API data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - View
    
    func updateView() {
        toggleSearch(enable: true)
        updateCalendar()
    }
    
    func toggleSearch(enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController {
            destination.courses = courses
            destination.courseDetailsDelegate = self
        } else if let destination = segue.destination as? CourseDetailsViewController {
            destination.delegate = self
        }
    }

}


// MARK: - Calendar generation
extension TimeTableViewController {
    /// Sets up all five day views in the calendar.
    func updateCalendar() {
        guard let courses = courses,
            let timeTable = timeTable else { return }
        
        var daySchedules: [[Int: Int]] = []
        
        // Set up days
        for _ in 0...4 {
            days.append(TimeTableDay(courses: []))
            daySchedules.append([:])
        }
        
        // Group time table courses by day
        for code in timeTable.courseCodes {
            // Get course from full list to find day and end time
            guard let course = courses.results.first(where: { $0.code == code }) else { continue }
            for day in course.dayNumbers {
                let item = TimeTableItem(courseCode: course.code, startTime: course.startTime)
                let startBlock = blocksFromTime(course.startTime)
                daySchedules[day][startBlock] = blocksFromTime(course.endTime)
                days[day].courses.append(item)
            }
        }
        
        for day in 0...4 {
            getDaySchedule(daySchedules[day], for: day)
        }
    }
    
    /// Gets the user's time table from the model.
    func getDaySchedule(_ schedule: [Int: Int], for day: Int) {
        // test
//        let daySchedule: [Int: Int] = [
//            blocksFromTime("10:00"): blocksFromTime("11:00"),
//            blocksFromTime("12:00"): blocksFromTime("12:30"),
//            blocksFromTime("13:30"): blocksFromTime("15:00")
//        ]
        
        // Get end times and convert both times to blocks; will be sorted later
//        var schedule: [Int: Int] = [:]
//
//        for course in days[day].courses {
//            let startBlock = blocksFromTime(course.startTime!)
//            // Find the matching course
//            guard let sameCourse = courses!.results.first(where: { $0.code == course.courseCode }) else { continue }
//            // Get the block for end time
//            schedule[startBlock] = blocksFromTime(sameCourse.endTime)
//        }
        
        var stackView = UIStackView()
        switch day {
        case 0: stackView = mondayStackView
        case 1: stackView = tuesdayStackView
        case 2: stackView = wednesdayStackView
        case 3: stackView = thursdayStackView
        case 4: stackView = fridayStackView
        default:
            fatalError("Cannot populate stack view: Day out of five-day range.")
        }
        print("day \(day): \(schedule)")
        updateDay(stackView, courses: schedule)
    }
    
    /// Calculates the vertical position on the calendar for a given time.
    func blocksFromTime(_ time: String) -> Int {
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
    
    /// Creates all rectangular calendar entries, including empty spaces, for one day.
    func makeDayBlocks(_ courses: [Int: Int]) -> [Int: Int] {
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
    
    /// Updates one day stack with all the subviews representing that day's schedule.
    func updateDay(_ stackView: UIStackView, courses: [Int: Int]) {
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
}


// MARK: - Course details delegate
extension TimeTableViewController: CourseDetailsViewControllerDelegate {
    func didRegisterCourse(code: String) {
        timeTable?.courseCodes.append(code)
        // Refresh timetable
        // TODO: Have this update only the relevant day
        DispatchQueue.main.async { self.updateCalendar() }
    }
    
    func didUpdateMemo() {
        // TODO: Implement
    }
}
