//
//  CourseViewModel.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

class CourseViewModel {
    
    // MARK: - Properties
    
    /// The `Course` model owned by this view model.
    fileprivate let course: Course
    
    let title: String
    var location: String { return course.location }
    
    
    // MARK: - Methods
    
    init(_ course: Course) {
        self.course = course
        self.title = course.title
    }
    
}


class CourseDetailsCourseViewModel: CourseViewModel {
    
    // MARK: - Properties
    
    // FIXME: Sort days of week in order (enum?)
    
    var timeAndDate: String {
        let time = "\(course.startTime) - \(course.endTime)"
        let date = "(\(course.days.joined(separator: "), (")))"
        return "강의실 : \(time) | \(date)"
    }
    
    var code: String { return "교과목 코드 : \(course.code)" }
    var professor: String { return "담당 교수 : \(course.professor)" }
    override var location: String { return "강의실 : \(super.location)" }
    
    let description: String
    
    // MARK: - Methods
    
    override init(_ course: Course) {
        self.description = course.description
        super.init(course)
    }
    
}


class SearchCourseViewModel: CourseViewModel {
    // TODO: Implement
}
