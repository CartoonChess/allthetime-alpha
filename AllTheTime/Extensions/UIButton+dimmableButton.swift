//
//  UIButton+dimmableButton.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit


class DimmableButton: UIButton {
    
    override var isEnabled: Bool {
        willSet {
            if newValue {
                self.alpha = 1.0
            } else {
                self.alpha = 0.5
            }
        }
    }
    
}
