//
//  CategoryCell.swift
//  intermine-ios
//
//  Created by Nadia on 7/21/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import UIKit

class CategoryCell: TypeColorCell {
    
    @IBOutlet weak var checkImageView: UIImageView?
    static let identifier = "CategoryCell"
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var typeColorView: UIView?
    
    var index: Int = 0
    
    var formattedFacet: FormattedFacet? {
        didSet {
            let title = formattedFacet?.getTitle()
            titleLabel?.text = title
            countLabel?.text = formattedFacet?.getCount()
            typeColorView?.backgroundColor = getSideColor(categoryType: title)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView?.image = Icons.check
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hideCheck()
    }
    
    func hideCheck() {
        checkImageView?.isHidden = true
    }
    
    func showCheck() {
        checkImageView?.isHidden = false
    }

}
