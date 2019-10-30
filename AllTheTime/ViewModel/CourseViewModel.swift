//
//  CourseViewModel.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

class CourseViewModel {
    
    // MARK: - Properties
    
    private let course: Course
    
    let title, code, location, professor, description: String
    
    var timeAndDate: String {
        let time = "\(course.startTime) - \(course.endTime)"
        let date = "(\(course.days.joined(separator: "), (")))"
        return "\(time) | \(date)"
    }
    
    
    // MARK: - Methods
    
    init(_ course: Course) {
        self.course = course
        
        self.title = course.title
        self.code = course.code
        self.location = course.location
        self.professor = course.professor
        self.description = course.description
    }
    
}
