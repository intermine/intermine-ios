//
//  TemplateDetailBaseCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class TemplateDetailBaseCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var valueTextField: UITextField?
    
    var index: Int? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        valueTextField?.delegate = self
        valueTextField?.addTarget(self, action: #selector(textFieldEdited(_:)), for: UIControlEvents.editingChanged)
    }
    
    func textFieldEdited(_ sender : UITextField) {
        guard let index = self.index else {
            return
        }
        var info: [String: Any] = [:]
        if let value = sender.text {
            info = ["value": value, "index": index]
        } else {
            info = ["value": "", "index": index]
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.valueChanged), object: self, userInfo: info)
    }

}
