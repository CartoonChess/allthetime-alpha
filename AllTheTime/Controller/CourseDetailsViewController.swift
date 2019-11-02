//
//  CourseDetailsViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

/// Delegates will be informed of updates to registered courses.
protocol CourseDetailsViewControllerDelegate {
    func didRegisterCourse(code: String)
    func didUpdateMemo()
}

class CourseDetailsViewController: UIViewController {
    
    // MARK: - Properties
    var course: CourseDetailsCourseViewModel?
    var delegate: CourseDetailsViewControllerDelegate?
    
    let memoSegue = "addMemo"
    
    // MARK: IBOutlets
    // Labels
    @IBOutlet weak var timeAndDayLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var professorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    // Non-labels
    @IBOutlet weak var registerCourseButton: UIButton!
    
    
    // MARK: - Methods
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: Large title navigation bar is jumpy with scroll view
        
        updateView()
    }
    
    // MARK: View
    
    func updateView() {
        // TODO: Use dependency injection so this isn't an optional (also in registerCourse())
        guard let course = course else { return }
        
        title = course.title
        
        timeAndDayLabel.text = course.timeAndDate
        codeLabel.text = course.code
        professorLabel.text = course.professor
        locationLabel.text = course.location
        
        descriptionLabel.text = course.description
        
        // TODO: Change button to memo button if course is registered
        // TODO: Disable memo button if course already has three memos
    }
    
    // MARK: Registration
    
    @IBAction func registerCourseButtonTapped() {
        registerCourse()
    }
    
    func registerCourse() {
        guard let course = course else { return }
        TimeTable.register(for: course.unformattedCode) { result in
            switch result {
            case .success(let message):
                print("Successfully registered for course: \(message)")
                self.delegate?.didRegisterCourse(code: course.unformattedCode)
                // TODO: Show confirmation of registration, and update button
            case .failure(let error):
                print("Failed to register for course: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Navigation
    
    // TODO: Segue to memo VC and pass course code

}
