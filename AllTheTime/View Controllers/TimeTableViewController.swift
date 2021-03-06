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
    
    var weeklyCalendar: WeeklyCalendar?
    
    // MARK: IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var previousWeekButton: UIButton!
    @IBOutlet weak var thisWeekButton: UIButton!
    @IBOutlet weak var nextWeekButton: UIButton!
    
    @IBOutlet weak var hoursStackView: UIStackView!
    @IBOutlet weak var mondayStackView: UIStackView!
    @IBOutlet weak var tuesdayStackView: UIStackView!
    @IBOutlet weak var wednesdayStackView: UIStackView!
    @IBOutlet weak var thursdayStackView: UIStackView!
    @IBOutlet weak var fridayStackView: UIStackView!
    
    // Hour labels
    @IBOutlet weak var hour9Label: UILabel!
    @IBOutlet weak var hour10Label: UILabel!
    @IBOutlet weak var hour11Label: UILabel!
    @IBOutlet weak var hour12Label: UILabel!
    @IBOutlet weak var hour13Label: UILabel!
    @IBOutlet weak var hour14Label: UILabel!
    @IBOutlet weak var hour15Label: UILabel!
    @IBOutlet weak var hour16Label: UILabel!
    @IBOutlet weak var hour17Label: UILabel!
    
    
    // MARK: - Methods
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Main view loaded.")
        
        // Disable most functions until after courses are loaded
        toggleSearch(enable: false)
        toggleDateChangeButtons(enable: false)
        
        // Get all courses from API
        fetchData()
        
        // Pass stack views to calendar creator
        let dayStacks: [UIStackView] = [
            mondayStackView,
            tuesdayStackView,
            wednesdayStackView,
            thursdayStackView,
            fridayStackView
        ]
        weeklyCalendar = WeeklyCalendar(dayStacks: dayStacks)
        weeklyCalendar?.delegate = self
        
        // Remove background/lines from hour stack
        hoursStackView.addBackground(color: .systemAppearanceBackground)
        offsetHourLabels()
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
        updateDateLabel()
        toggleSearch(enable: true)
        toggleDateChangeButtons(enable: true)
        
        guard let courses = courses,
            let timeTable = timeTable,
            let memos = memos else { return }
        weeklyCalendar?.reloadWeek(courses: courses, timeTable: timeTable, memos: memos)
    }
    
    func toggleSearch(enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
    
    func toggleDateChangeButtons(enable: Bool) {
        previousWeekButton.isEnabled = enable
        thisWeekButton.isEnabled = enable
        nextWeekButton.isEnabled = enable
    }
    
    
    // MARK: - Change date
    
    @IBAction func previousWeekButtonTapped() {
        updateDate(offsetWeekBy: -1)
    }
    
    @IBAction func nextWeekButtonTapped() {
        updateDate(offsetWeekBy: 1)
    }
    
    @IBAction func thisWeekButtonTapped() {
        updateDate(offsetWeekBy: 0)
    }
    
    // Changes the display of the year and month, as well as day numbers.
    func updateDate(offsetWeekBy offset: Int) {
        weeklyCalendar?.changeWeek(by: offset)
        updateDateLabel()
    }
    
    func updateDateLabel() {
        guard let year = weeklyCalendar?.displayDate.year,
            let month = weeklyCalendar?.displayDate.month else { return }
        dateLabel.text = "\(year)년 \(month)월"
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController {
            destination.courses = courses
            destination.courseDetailsDelegate = self
        } else if let destination = segue.destination as? CourseDetailsViewController,
            let viewModel = sender as? CourseDetailsCourseViewModel {
            destination.course = viewModel
            destination.delegate = self
        }
    }

}


// MARK: - Delegation
extension TimeTableViewController: CourseDetailsViewControllerDelegate {
    func didRegisterCourse(code: String) {
        timeTable?.courseCodes.append(code)
        // Refresh timetable
        // TODO: Have this update only the relevant day
//        DispatchQueue.main.async { self.updateCalendar() }
    }
    
    func didUpdateMemo(for course: String) {
        // Refresh timetable
        // TODO: Update single course
//        let course = courses!.results.first { $0.code == course }
//        weeklyCalendar?.updateCourse(course!)
    }
    
    func userIsRegisteredInCourse(code: String) -> Bool {
        timeTable?.courseCodes.contains(code) ?? true
    }
    
    func canAddMemo(for course: String) -> Bool {
        memos?.all[course]?.count ?? 0 < 3
    }
}

extension TimeTableViewController: WeeklyCalendarDelegate {
    var courseDetailsSegue: String { "courseDetails" }
    
    func didTapCalendarBlock(_ block: CalendarBlockView) {
        guard let viewModel = block.viewModel?.convert(to: CourseDetailsCourseViewModel.self) else { return }
        performSegue(withIdentifier: courseDetailsSegue, sender: viewModel)
    }
}

// Hour labels
extension TimeTableViewController {
    func offsetHourLabels() {
        let hourLabels = [
            hour9Label!,
            hour10Label!,
            hour11Label!,
            hour12Label!,
            hour13Label!,
            hour14Label!,
            hour15Label!,
            hour16Label!,
            hour17Label!
        ]
        
        for label in hourLabels {
            let currentText = label.text!
            label.text = "\(currentText)\n"
        }
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
