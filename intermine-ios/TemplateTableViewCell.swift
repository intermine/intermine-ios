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
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var userImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView?.image = Icons.user
    }
    
    var template: Template? {
        didSet {
            if let info = template?.getInfo() {
                do {
                    let html = "<head><style>a{color: grey;text-decoration: none;}div.main{color: grey;font-family: -apple-system;font-size:17px;}</style></head><div class=\"main\">" + info + "</div>"
                    let attrStr = try NSAttributedString(
                        data: html.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                        options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                        documentAttributes: nil)
                    descriptionLabel?.attributedText = attrStr
                } catch _ {
                    
                }
            }
            titleLabel?.text = template?.getTitle()
            containerView?.layer.borderWidth = 1
            containerView?.layer.borderColor = Colors.gray56.withAlphaComponent(0.3).cgColor
            if let template = self.template {
                userImageView?.isHidden = !template.getAuthd()
            }
        }
    }
}
