//
//  FetchedTemplateCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class FetchedCell: UITableViewCell {
    
    static let identifier = "FetchedCell"
    @IBOutlet weak var descriptionLabel: UILabel?
    
    var representedData: [String:String] = [:] {
        didSet {
            var infoString = ""
            var gen = 0
            for (key, value) in self.representedData {
                gen += 1
                if value != "<null>" {
                    var currentString = "\(key): \(value)\n"
                    if gen == self.representedData.count {
                        currentString = "\(key): \(value)"
                    }
                    infoString.append(currentString)
                }
            }
            descriptionLabel?.text = infoString
        }
    }
    
    var data: SearchResult? {
        didSet {
            if let data = self.data {
                let viewableRepresentation: [String:String] = data.viewableRepresentation()
                var infoString = ""
                var gen = 0
                for (key, value) in viewableRepresentation {
                    gen += 1
                    if value != "<null>" {
                        var currentString = "\(key): \(value)\n"
                        if gen == viewableRepresentation.count {
                            currentString = "\(key): \(value)"
                        }
                        infoString.append(currentString)
                    }
                }
                descriptionLabel?.text = infoString
            }
        }
    }

}
