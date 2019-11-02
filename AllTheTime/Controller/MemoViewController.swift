//
//  MemoViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var bodyTextView: UITextView!
    
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        
        // TODO: Keyboard/scrolling management (or will ScrollView automate this?)
        
        // TODO: TextView placeholder text
    }
    
    func updateView() {
        bodyTextView.layer.borderColor = UIColor.lightGray.cgColor
    }

}

// MARK: - Networking
extension MemoViewController {
    
}
