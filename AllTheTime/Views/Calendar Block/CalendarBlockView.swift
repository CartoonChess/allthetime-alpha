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
    @IBOutlet var contentView: CalendarBlockView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    // MARK: - Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        construct()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        construct()
    }
    
    func construct() {
        // Init nib
        Bundle(for: CalendarBlockView.self).loadNibNamed("CalendarBlockView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }

}
