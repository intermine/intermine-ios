//
//  ListsTableViewCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/14/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class ListTableViewCell: TypeColorCell {
    
    static let identifier = "ListCell"
    @IBOutlet weak var colorTypeView: UIView?
    @IBOutlet weak var userImageView: UIImageView?
    
    @IBOutlet weak var colorView: UIView?
    
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
                if let type = list.getType() {
                    let color = getBackgroundColor(categoryType: type)
                    colorView?.backgroundColor = color
                }
                userImageView?.isHidden = !list.getAuthd()
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var countLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView?.image = Icons.user
    }

}
