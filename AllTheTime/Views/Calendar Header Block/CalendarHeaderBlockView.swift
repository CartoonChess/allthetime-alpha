//
//  CalendarHeaderBlockView.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class CalendarHeaderBlockView: UIView {

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
        dayNumberLabel.text = viewModel.dayNumber
    }

}
