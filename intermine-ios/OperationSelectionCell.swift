//
//  OperationSelectionCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit


protocol OperationSelectionCellDelegate: class {
    func operationSelectionCellDidTapSelectButton(cell: OperationSelectionCell)
}

class OperationSelectionCell: TemplateDetailBaseCell {
    
    static let identifier = "OperationSelectionCell"
    @IBOutlet weak var operationLabel: UILabel?
    @IBOutlet weak var selectOperationButton: UIButton?
    
    weak var delegate: OperationSelectionCellDelegate?
    
    var query: TemplateQuery? {
        didSet {
            operationLabel?.text = self.query?.getOperation()
            valueTextField?.text = self.query?.getValue()
        }
    }
    
    var operation: String? = "==" {
        didSet {
            operationLabel?.text = self.operation
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectOperationButton?.setTitle(String.localize("Templates.CTA.SelectOperation"), for: .normal)
        selectOperationButton?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        selectOperationButton?.titleLabel?.numberOfLines = 2
        selectOperationButton?.titleLabel?.textAlignment = NSTextAlignment.center
        NotificationCenter.default.addObserver(self, selector: #selector(self.operationChanged(_:)), name: NSNotification.Name(rawValue: Notifications.operationChanged), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func operationSelectButtonTapped(_ sender: Any) {
        self.delegate?.operationSelectionCellDidTapSelectButton(cell: self)
    }
    
    // MARK: Notification when operation is changed
    
    func operationChanged(_ notification: NSNotification) {
        if let op = notification.userInfo?["op"] as? String {
            self.query?.changeOperation(operation: op)
            operationLabel?.text = op
        }
    }
}
