//
//  CalendarBlockView.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class CalendarBlockView: UIView {
    
    // MARK: - Properties
    var viewModel: CalendarBlockCourseViewModel? {
        didSet { updateView() }
    }
    // IBOutlets
    @IBOutlet var contentView: CalendarBlockView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    // MARK: - Methods
    
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
        Bundle(for: CalendarBlockView.self).loadNibNamed("CalendarBlockView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    func updateView() {
        guard let viewModel = viewModel else { return }
        
        // TODO: Have this not alpha on top of grey
        contentView.backgroundColor = viewModel.backgroundColor
        
        titleLabel.text = viewModel.title
        locationLabel.text = viewModel.location
        
        titleLabel.textColor = viewModel.color
        locationLabel.textColor = viewModel.color
    }

}
