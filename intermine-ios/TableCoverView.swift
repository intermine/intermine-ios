//
//  TableCoverView.swift
//  intermine-ios
//
//  Created by Nadia on 5/13/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class TableCoverView: BaseView {

    @IBOutlet weak var messageLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel?.text = String.localize("General.NothingFound")
    }

}
