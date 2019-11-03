//
//  MemoViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

protocol MemoViewControllerDelegate {
    func didUpdateMemo()
}

class MemoViewController: UIViewController {
    
    // MARK: - Properties
    var courseCode: String?
    var delegate: MemoViewControllerDelegate?
    // IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyTextView.delegate = self
        
        updateView()
        
        // TODO: Keyboard/scrolling management (or will ScrollView automate this?)
        
        // TODO: TextView placeholder text
        
        // TODO: Memo type (UI/code)
    }
    
    func updateView() {
        bodyTextView.layer.borderColor = UIColor.lightGray.cgColor
        toggleAddButton()
    }
    
    // MARK: Add button
    
    @IBAction func titleTextFieldDidChange() {
        fieldsDidChange()
    }
    
    func fieldsDidChange() {
        toggleAddButton()
    }
    
    /// Enable add button when at least one field is filled out
    func toggleAddButton() {
        let enable = (!titleTextField.text!.isEmpty || !bodyTextView.text!.isEmpty)
        addButton.isEnabled = enable
    }
    
    @IBAction func addButtonTouched() {
        addMemo()
    }
    
    // MARK: Navigation
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        // TODO: Implement
    }

}

// MARK: - Networking
extension MemoViewController {
    func addMemo() {
        guard let courseCode = courseCode else { return }
        
        var title = titleTextField.text ?? ""
        if title.isEmpty { title = "메모" }
        var body = bodyTextView.text ?? ""
        if body.isEmpty { body = "설명 없음" }
        let memo = Memo(title: title,
                        body: body,
                        type: .study,
                        courseCode: courseCode)
        
        Memos.add(memo) { result in
            switch result {
            case .success(let message):
                print("Successfully added memo: \(message)")
                // TODO: Update course VC (delegate), unwind
//                self.delegate?.didRegisterCourse(code: course.unformattedCode)
//                unwind(for: <#T##UIStoryboardSegue#>, towards: <#T##UIViewController#>)
            case .failure(let error):
                print("Error adding memo: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - TextView delegate
extension MemoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        fieldsDidChange()
    }
}
