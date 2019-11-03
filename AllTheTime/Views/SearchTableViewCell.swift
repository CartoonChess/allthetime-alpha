//
//  SearchTableViewCell.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/01.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var course: SearchCourseViewModel? {
        willSet {
            if let course = newValue { construct(using: course) }
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeAndDayLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var professorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    // MARK: - Methods
    
    private func construct(using course: SearchCourseViewModel) {
        containerView.layer.borderColor = UIColor.lightGray.cgColor
            
        titleLabel.text = course.title
        timeAndDayLabel.text = course.timeAndDate
        codeLabel.text = course.code
        professorLabel.text = course.professor
        locationLabel.text = course.location
    }

}
