//
//  TagView.swift
//  intermine-ios
//
//  Created by Nadia on 8/24/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class TagView: UIView {

    @IBOutlet weak var label: UILabel?
    
    var templateTag: String = "" {
        didSet {
            backgroundColor = TagColorDefine.getTagColor(tagType: templateTag)
            if let firstLetter = templateTag.characters.first {
                label?.text = String(firstLetter).capitalized
            }
        }
    }
    

}
