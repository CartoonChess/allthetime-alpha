//
//  CalendarHeaderBlockView.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class CalendarHeaderBlockView: UIView {
    
    // TODO: Adjust text size per space constraints (e.g. rotating device)

    // MARK: - Properties
    var viewModel: CalendarHeaderBlockViewModel? {
        didSet { updateView() }
    }
    // IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    
    
    // MARK: - Methods
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initAny()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initAny()
    }
    
    private func initAny() {
        // Init nib
        Bundle(for: CalendarHeaderBlockView.self).loadNibNamed("CalendarHeaderBlockView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    private func updateView() {
        guard let viewModel = viewModel else { return }
        dayNameLabel.text = viewModel.dayName
        updateDayNumber(viewModel.dayNumber, isToday: viewModel.isToday)
    }
    
    // Must call this function when updating day to make sure it is coloured appropriately
    func updateDayNumber(_ day: String, isToday: Bool) {
        dayNumberLabel.text = day
        
        if isToday {
            dayNameLabel.textColor = .linkColor
            dayNumberLabel.textColor = .white
            dayNumberLabel.backgroundColor = .linkColor
        } else {
            dayNameLabel.textColor = .lightGray
            dayNumberLabel.textColor = .lightGray
            dayNumberLabel.backgroundColor = .systemAppearanceBackground
        }
    }

}
