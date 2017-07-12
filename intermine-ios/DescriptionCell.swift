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
    
    private var layoutManager: NSLayoutManager?
    private var textContainer: NSTextContainer?
    private var textStorage: NSTextStorage?
    
    var info: String? = "" {
        didSet {
            if let info = self.info {
                do {
                    let html = "<head><style>a{color: grey;text-decoration: none;}div.main{color: grey;font-family: -apple-system;font-size:17px;text-align: center;}</style></head><div class=\"main\">" + info + "</div>"
                    let attrStr = try NSAttributedString(
                        data: html.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                        options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                        documentAttributes: nil)
                    descriptionLabel?.attributedText = attrStr
                } catch _ {
                    
                }
            }
        }
    }
    
    var title: String? = "" {
        didSet {
            titleLabel?.text = self.title
        }
    }
    
}
