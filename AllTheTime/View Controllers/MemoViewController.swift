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
    var typeIndex: Int = 0
    var possibleTypes: [Memo.MemoType] = []
    var possibleImages: [UIImage] = []
    // IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyTextView.delegate = self
        
        updateView()
        
        // TODO: Keyboard/scrolling management (or will ScrollView automate this?)
        
        // TODO: TextView placeholder text
    }
    
    func updateView() {
        bodyTextView.layer.borderColor = UIColor.lightGray.cgColor
        toggleAddButton()
        updatePossibleTypes()
        updateMemoType()
    }
    
    // MARK: Add button
    
    @IBAction func titleTextFieldDidChange() {
        fieldsDidChange()
    }
    
    func fieldsDidChange() {
        toggleAddButton()
    }
    
    /// Enable add button when at least one field is filled out
    func toggleAddButton(_ enable: Bool? = nil) {
        var shouldEnable = false
        if let enable = enable {
            shouldEnable = enable
        } else {
            shouldEnable = (!titleTextField.text!.isEmpty || !bodyTextView.text!.isEmpty)
        }
        addButton.isEnabled = shouldEnable
    }
    
    @IBAction func addButtonTouched() {
        toggleAddButton(false)
        addMemo()
    }
    
    
    // MARK: Type chooser
    
    @IBAction func typeButtonTouched() {
        updateMemoType()
    }
    
    func updatePossibleTypes() {
        if !possibleTypes.isEmpty {
            if possibleTypes.contains(.study) {
                possibleImages.append(UIImage(named: Keys.Image.studyMemo)!)
            }
            if possibleTypes.contains(.assignment) {
                possibleImages.append(UIImage(named: Keys.Image.assignmentMemo)!)
            }
            if possibleTypes.contains(.exam) {
                possibleImages.append(UIImage(named: Keys.Image.examMemo)!)
            }
            
            typeIndex = possibleTypes.count - 1
        }
    }
    
    func updateMemoType() {
        // Advance to next
        if typeIndex < possibleTypes.count - 1 {
            typeIndex += 1
        } else {
            typeIndex = 0
        }
        
        // Change button image to reflect type
        updateTypeButtonImage()
    }
    
    func updateTypeButtonImage() {
        typeButton.setImage(possibleImages[typeIndex], for: .normal)
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
                        type: possibleTypes[typeIndex],
                        courseCode: courseCode)
        
        Memos.add(memo) { result in
            switch result {
            case .success(let message):
                print("Successfully added memo: \(message)")
                DispatchQueue.main.async {
                    self.delegate?.didUpdateMemo()
                    self.navigationController?.popViewController(animated: true)
                }
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
