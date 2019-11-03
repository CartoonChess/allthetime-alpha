//
//  CalendarBlockView.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/03.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

protocol CalendarBlockViewDelegate {
    func didTapCalendarBlock(_ block: CalendarBlockView)
}

// We subclass UIControl to get touchUpInside
class CalendarBlockView: UIControl {
    
    // MARK: - Properties
    var viewModel: CalendarBlockCourseViewModel? {
        didSet { updateView() }
    }
    var delegate: CalendarBlockViewDelegate?
    // IBOutlets
    @IBOutlet var contentView: CalendarBlockView!
    @IBOutlet weak var leftBarView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    // Memos
    @IBOutlet weak var memo1Image: UIImageView!
    @IBOutlet weak var memo2Image: UIImageView!
    @IBOutlet weak var memo3Image: UIImageView!
    @IBOutlet weak var memo1Label: UILabel!
    @IBOutlet weak var memo2Label: UILabel!
    @IBOutlet weak var memo3Label: UILabel!
    
    
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
        Bundle(for: CalendarBlockView.self).loadNibNamed("CalendarBlockView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    private func updateView() {
        guard let viewModel = viewModel else { return }
        
        contentView.backgroundColor = viewModel.backgroundColor
        leftBarView.backgroundColor = viewModel.color
        
        titleLabel.text = viewModel.title
        locationLabel.text = viewModel.location
        
        titleLabel.textColor = viewModel.color
        locationLabel.textColor = viewModel.color
        
        memo1Label.textColor = viewModel.color
        memo2Label.textColor = viewModel.color
        memo3Label.textColor = viewModel.color
    }
    
    func updateMemos(_ mixedMemos: [Memo]) {
        // We will check whether we have each kind of memo
        var enableStudy = false
        var enableAssignment = false
        var enableExam = false
        // Put them in order
        var memos: [Memo] = []
        
        if memos.count > 0 {
            // Get possible memos
            if let study = memos.first(where: { $0.type == .study }) {
                memos.append(study)
                enableStudy = true
            }
            if let assignment = memos.first(where: { $0.type == .assignment }) {
                memos.append(assignment)
                enableAssignment = true
            }
            if let exam = memos.first(where: { $0.type == .exam }) {
                memos.append(exam)
                enableExam = true
            }
            
            if memos.count > 0 {
                memo1Label.text = memos[0].title
                memo1Image.image = updateMemoImage(type: memos[0].type)
                if memos.count > 1 {
                    memo2Label.text = memos[1].title
                    memo1Image.image = updateMemoImage(type: memos[1].type)
                    if memos.count > 2 {
                        memo3Label.text = memos[2].title
                        memo1Image.image = updateMemoImage(type: memos[2].type)
                    }
                }
            }
        }
        
        toggleMemoVisibility(study: enableStudy, assignment: enableAssignment, exam: enableExam)
    }
    
    private func updateMemoImage(type: Memo.MemoType) -> UIImage {
        switch type {
        case .assignment:
            return UIImage(named: Keys.Image.assignmentMemo)!
        case .exam:
            return UIImage(named: Keys.Image.examMemo)!
        default:
            return UIImage(named: Keys.Image.studyMemo)!
        }
    }
    
    private func toggleMemoVisibility(study: Bool, assignment: Bool, exam: Bool) {
        memo1Label.isHidden = study
        memo1Image.isHidden = study
        
        memo2Label.isHidden = assignment
        memo2Image.isHidden = assignment
        
        memo3Label.isHidden = exam
        memo3Image.isHidden = exam
    }
    
    // MARK: Gestures

    @IBAction func didTouchUpInsideContentView(_ sender: Any) {
        delegate?.didTapCalendarBlock(self)
    }
}
