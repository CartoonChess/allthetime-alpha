//
//  CourseDetailsViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class CourseDetailsViewController: UIViewController {
    
    // MARK: - Properties
    var course: CourseDetailsCourseViewModel?
    
    // MARK: IBOutlets
    @IBOutlet weak var timeAndDayLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var professorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Methods
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: Large title navigation bar is jumpy with scroll view

        // TODO: This should be passed from the timetable/search view rather than fetched from server
//        Courses.fetch(code: "PG1807-15") { result in
//            switch result {
//            case .success(let courses):
//                for course in courses.results {
//                    self.course = CourseDetailsCourseViewModel(course)
//                    DispatchQueue.main.async {
//                        self.updateView()
//                    }
//                }
//            case .failure(let error):
//                print("Could not fetch courses: \(error.localizedDescription)")
//            }
//        }
    }
    
    // MARK: Other
    
    func updateView() {
        // TODO: Use dependency injection so this isn't an optional
        guard let course = course else { return }
        
        title = course.title
        
        timeAndDayLabel.text = course.timeAndDate
        codeLabel.text = course.code
        professorLabel.text = course.professor
        locationLabel.text = course.location
        
        descriptionLabel.text = course.description
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
