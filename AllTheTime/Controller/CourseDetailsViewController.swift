//
//  CourseDetailsViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class CourseDetailsViewController: UIViewController {
    
    // TODO: Get everything except the bottom button into a scroll view (maybe a static table?)
    
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
        
        descriptionLabel.text = "강의 설명 없음 Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vitae suscipit tellus mauris a diam maecenas. Pharetra convallis posuere morbi leo. Metus aliquam eleifend mi in nulla posuere sollicitudin aliquam. Tristique magna sit amet purus gravida quis blandit. Velit aliquet sagittis id consectetur purus ut faucibus pulvinar elementum. Id nibh tortor id aliquet lectus proin nibh. Lobortis scelerisque fermentum dui faucibus in ornare quam. Ornare aenean euismod elementum nisi quis eleifend quam adipiscing. Et netus et malesuada fames ac turpis egestas integer eget. Cursus turpis massa tincidunt dui ut ornare lectus sit. Integer malesuada nunc vel risus commodo. In hac habitasse platea dictumst vestibulum. Penatibus et magnis dis parturient. At imperdiet dui accumsan sit amet. Vel risus commodo viverra maecenas accumsan lacus vel facilisis volutpat. At auctor urna nunc id cursus. Vehicula ipsum a arcu cursus vitae congue mauris rhoncus aenean. Dui sapien eget mi proin sed libero enim sed. Maecenas pharetra convallis posuere morbi./n/nPlacerat duis ultricies lacus sed turpis tincidunt id aliquet risus. Nulla posuere sollicitudin aliquam ultrices. Consectetur purus ut faucibus pulvinar. Aliquet nec ullamcorper sit amet risus nullam. Purus viverra accumsan in nisl nisi scelerisque eu. Feugiat in ante metus dictum at tempor commodo ullamcorper. Non arcu risus quis varius quam quisque id. Ipsum dolor sit amet consectetur adipiscing elit duis tristique sollicitudin. Fermentum dui faucibus in ornare quam viverra. Purus faucibus ornare suspendisse sed nisi. Non enim praesent elementum facilisis leo vel fringilla. Ut enim blandit volutpat maecenas. Feugiat nisl pretium fusce id velit ut tortor pretium viverra. Viverra ipsum nunc aliquet bibendum enim facilisis gravida neque. Dis parturient montes nascetur ridiculus mus mauris vitae ultricies. Dolor sit amet consectetur adipiscing elit duis tristique. Semper feugiat nibh sed pulvinar. Porttitor massa id neque aliquam vestibulum morbi. Vehicula ipsum a arcu cursus vitae congue. Nunc lobortis mattis aliquam faucibus./n/nRisus in hendrerit gravida rutrum quisque non tellus orci ac. Amet facilisis magna etiam tempor orci eu lobortis elementum. Tortor condimentum lacinia quis vel. Tellus cras adipiscing enim eu turpis. Ut ornare lectus sit amet est placerat in egestas. Sagittis aliquam malesuada bibendum arcu vitae. Gravida arcu ac tortor dignissim convallis aenean et tortor at. Turpis massa tincidunt dui ut ornare lectus sit. Leo duis ut diam quam nulla porttitor massa id neque. Pretium fusce id velit ut tortor pretium viverra suspendisse. Faucibus vitae aliquet nec ullamcorper sit amet risus nullam eget. At tellus at urna condimentum mattis. Sed id semper risus in. Auctor neque vitae tempus quam pellentesque. Egestas diam in arcu cursus euismod quis viverra nibh cras. Et pharetra pharetra massa massa ultricies mi. Est ante in nibh mauris cursus mattis molestie a. Id eu nisl nunc mi. Nisi vitae suscipit tellus mauris a diam maecenas. Mauris pharetra et ultrices neque ornare aenean euismod."
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
