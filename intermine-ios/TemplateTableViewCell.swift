//
//  ResultsTableViewCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class TemplateTableViewCell: UITableViewCell {
    
    static let identifier = "TemplateCell"
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    
    var template: Template? {
        didSet {
            descriptionLabel?.text = template?.getInfo()
            titleLabel?.text = template?.getTitle()
        }
    }
}
