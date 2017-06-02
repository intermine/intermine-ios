//
//  DescriptionCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit


class DescriptionCell: UITableViewCell {
    
    static let identifier = "DescripitonCell"
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    var info: String? = "" {
        didSet {
            descriptionLabel?.text = self.info
        }
    }
    
    var title: String? = "" {
        didSet {
            titleLabel?.text = self.title
        }
    }
    
}
