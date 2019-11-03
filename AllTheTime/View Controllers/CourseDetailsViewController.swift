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
    func userIsRegisteredInCourse(code: String) -> Bool
    func didRegisterCourse(code: String)
    func canAddMemo(for course: String) -> Bool
    func didUpdateMemo()
}

class CourseDetailsViewController: UIViewController {
    
    // MARK: - Properties
    var course: CourseDetailsCourseViewModel?
    var delegate: CourseDetailsViewControllerDelegate?
    
    var userIsRegistered: Bool = false
    
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
        
        updateRegisterCourseButton()
    }
    
    func updateRegisterCourseButton() {
        // If we can't see the delegate or course for some reason, safely disable button
        guard let delegate = delegate,
            let code = course?.unformattedCode else {
            registerCourseButton.isEnabled = false
            return
        }
        
        // Change register button to memo button if already registered
        userIsRegistered = delegate.userIsRegisteredInCourse(code: code)
        if userIsRegistered {
            registerCourseButton.setTitle("메모 추가", for: .normal)
            // Disable memo button if course already has three memos
            // TODO: Toggle this again when adding memo, in case we go over
            if !delegate.canAddMemo(for: code) {
                print("can't add memo")
                registerCourseButton.isEnabled = false
            }
        }
    }
    
    // MARK: Registration
    
    @IBAction func registerCourseButtonTapped() {
        if !userIsRegistered {
            registerCourse()
        } else {
            performSegue(withIdentifier: memoSegue, sender: self)
        }
    }
    
    func registerCourse() {
        guard let course = course else { return }
        TimeTable.register(for: course.unformattedCode) { result in
            switch result {
            case .success(let message):
                print("Successfully registered for course: \(message)")
                self.delegate?.didRegisterCourse(code: course.unformattedCode)
                DispatchQueue.main.async { self.updateRegisterCourseButton() }
                // TODO: Show confirmation of registration
            case .failure(let error):
                print("Failed to register for course: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MemoViewController {
            destination.courseCode = course?.unformattedCode
            destination.delegate = self
        }
    }
    
}

extension CourseDetailsViewController: MemoViewControllerDelegate {
    func didUpdateMemo() {
        // TODO: Update registration button
        // TODO: Inform own delegate to update time table view
    }
}
