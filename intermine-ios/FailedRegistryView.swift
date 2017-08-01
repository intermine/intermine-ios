//
//  FailedRegistryView.swift
//  intermine-ios
//
//  Created by Nadia on 7/22/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class FailedRegistryView: BaseView {

    @IBOutlet weak var messageLabel: UILabel?
    var messageText: String? {
        didSet {
            messageLabel?.text = messageText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel?.text = String.localize("Registry.Error.FailedToLoad")
    }

}
