//
//  LookupCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class LookupCell: TemplateDetailBaseCell {
    
    static let identifier = "LookupCell"
    @IBOutlet weak var titleLabel: UILabel?
    
    var query: TemplateQuery? {
        didSet {
            valueTextField?.text = self.query?.getValue()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.text = "Lookup"
    }
}
