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
    
    required init(_ course: Course) {
        self.course = course
        self.title = course.title
    }
    
    /// Returns the course as a different type of course view model
    func convert<ViewModel: CourseViewModel>(to viewModel: ViewModel.Type) -> ViewModel {
        ViewModel(course)
    }
}


// MARK: -
class SearchCourseViewModel: CourseViewModel {
    var timeAndDate: String {
        let time = "\(course.startTime) - \(course.endTime)"
        let date = "(\(course.dayStrings.joined(separator: "), (")))"
        return "\(time) | \(date)"
    }
    
    var code: String { return "교과목 코드 : \(course.code)" }
    var professor: String { return "담당 교수 : \(course.professor)" }
    override var location: String { return "강의실 : \(super.location)" }
}


// MARK: - 
class CourseDetailsCourseViewModel: SearchCourseViewModel {
    // MARK: - Properties
    
    override var timeAndDate: String { return "강의실 : \(super.timeAndDate)" }
    let description: String
    
    /// Provides the course code without any formatting. Should not be used for display purposes.
    var unformattedCode: String { return course.code }
    
    // MARK: - Methods
    
    required init(_ course: Course) {
        self.description = course.description
        super.init(course)
    }
}
