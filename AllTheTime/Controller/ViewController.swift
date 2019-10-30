//
//  ViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/29.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
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
        print("Loaded.")
        
        getDaySchedule()
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
            blocksFromTime("12:00"): blocksFromTime("12:30")
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
        while start <= endOfDay {
            // Add empty time where there is no course scheduled
            if let endOfCourse = courses[start] {
                // End empty block here, as long as it isn't the start of the day
                if start != startOfDay {
                    schedule[emptyBlock] = start
                    emptyBlock = 0
                }
                // Go to end of this course block
                start = endOfCourse
            } else if emptyBlock != 0 && grid.contains(start) {
                // End empty block and begin new one
                schedule[emptyBlock] = start
                emptyBlock = 0
                start += 1
            } else if emptyBlock == 0 {
                // Begin empty block
                emptyBlock = start
                start += 1
            } else {
                // If we were already in an empty block and found no course, just check the next block
                start += 1
            }
        }
        
        print(schedule)
        return schedule
    }
    
    func updateDay(_ stackView: UIStackView, courses: [Int: Int]) {
        // Add empty times into schedule
        let schedule = makeDayBlocks(courses)
        
//        // Course view
//        let courseView = UIView()
//        courseView.backgroundColor = UIColor.green
//
//        // Empty hour view
////        let emptyHourView = UIView()
////        emptyHourView.backgroundColor = UIColor.black
        
        // We will active all height constraints simultaneously
        var constraints: [NSLayoutConstraint] = []
        
//        for row in 1...rowsPerDay {
//            let emptyHourView = UIView()
//            emptyHourView.backgroundColor = UIColor.black
//            stackView.addArrangedSubview(emptyHourView)
//            let height = CGFloat(1.0 / Double(rowsPerDay))
//
//            // Set height constraint, but not on last cell, to avoid math errors
//            if row < rowsPerDay {
//                // Constant accounts for size of stack spacing (row border)
//                constraints.append(emptyHourView.heightAnchor.constraint(equalTo: emptyHourView.superview!.heightAnchor, multiplier: height, constant: -1))
//            }
//        }
        
        var grey: CGFloat = 0.0
        
        // FIXME: Need to do this in order somehow...
        for calendarItem in schedule {
            let calendarItemView = UIView()
                grey += 0.05
                let color = UIColor(white: grey, alpha: 1)
            calendarItemView.backgroundColor = color
            stackView.addArrangedSubview(calendarItemView)
            
            // Get height of view based on how long the time period is
            // FIXME: 30-min blocks returning 5 instead of 6
            print("key \(calendarItem.key), value \(calendarItem.value)")
            let blocks = calendarItem.value - calendarItem.key
            let height = CGFloat(Float(blocks) / Float(blocksPerDay))
            
            print("blocks: \(blocks)")
            print("Height: \(height)")
            
            // Set height constraint, but not on last cell, to avoid math errors
            if calendarItem.value < blocksPerDay {
                // Constant accounts for size of stack spacing (row border)
                constraints.append(calendarItemView.heightAnchor.constraint(equalTo: calendarItemView.superview!.heightAnchor, multiplier: height, constant: -1))
            }
        }

//        stackView.addArrangedSubview(courseView)
//        stackView.addArrangedSubview(emptyHourView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(constraints)
    }

}

