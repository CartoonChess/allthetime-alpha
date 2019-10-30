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
    var course: CourseViewModel?
    
    // MARK: IBOutlets
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: This should be passed from the timetable/search view rather than fetched from server
        Courses.fetch(code: "PG1807-15") { result in
            switch result {
            case .success(let courses):
                for course in courses.results {
                    self.course = CourseViewModel(course)
                    DispatchQueue.main.async {
                        self.title = self.course?.title
                        self.descriptionLabel.text = self.course?.description
                    }
                }
            case .failure(let error):
                print("Could not fetch courses: \(error.localizedDescription)")
            }
        }
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
