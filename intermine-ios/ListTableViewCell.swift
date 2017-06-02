//
//  ListsTableViewCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/14/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    static let identifier = "ListCell"
    
    var list: List? {
        didSet {
            // configure UI
            if let list = self.list {
                titleLabel?.text = list.getTitle()
                descriptionLabel?.text = list.getInfo()
                if let size = list.getSize() {
                    let sizeString = "\(size)"
                    countLabel?.text = sizeString
                }
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var countLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
