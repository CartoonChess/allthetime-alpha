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
    
    // 18 30-minute blocks, plus two blocks for weekday + day number
    let rowsPerDay = 20
    var blocksPerDay: Int {
        30 / 5 * rowsPerDay // 5-minute intervals
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var mondayStackView: UIStackView!
    
    
    // MARK: - Methods
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Main view loaded.")
        
        // Disable search until after courses are loaded
        toggleSearch(enable: false)
        
        // Get all courses from API
        fetchCourses() { error in
            if let error = error {
                print("Could not fetch courses: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async { self.updateView() }
        }
    }
    
    // MARK: - View
    
    func updateView() {
        toggleSearch(enable: true)
        getDaySchedule()
    }
    
    func toggleSearch(enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
    
    // MARK: Calendar
    
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
    
    func getDaySchedule() {
        let daySchedule: [Int: Int] = [
            blocksFromTime("10:00"): blocksFromTime("11:00"),
            blocksFromTime("12:00"): blocksFromTime("12:30"),
            blocksFromTime("13:30"): blocksFromTime("15:00")
        ]
        
        // Update view
        updateDay(mondayStackView, courses: daySchedule)
    }
    
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
        // FIXME: First (empty) block goes until first course, ignoring grid
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
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController {
            destination.courses = courses
        }
    }

}


// MARK: - Initial data fetch
extension TimeTableViewController {
    /// Fetch full course list
    func fetchCourses(completion: @escaping (Error?) -> Void) {
        
        // TODO: Show a loading spinner while waiting
        
        Courses.fetch() { result in
            switch result {
            case .success(let courses):
                self.courses = courses
                print("Fetched courses.")
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
