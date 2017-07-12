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
            descriptionLabel?.attributedText = self.labelContents(representedData: representedData)
        }
    }
    
    var data: SearchResult? {
        didSet {
            if let data = self.data {
                let viewableRepresentation: [String:String] = data.viewableRepresentation()
                descriptionLabel?.attributedText = self.labelContents(representedData: viewableRepresentation)
            }
        }
    }
    
    private func labelContents(representedData: [String: String]) -> NSMutableAttributedString {
        let infoString = NSMutableAttributedString(string: "")
        let mineString = NSMutableAttributedString(string: "")
        let typeString = NSMutableAttributedString(string: "")
        let resultingString = NSMutableAttributedString(string: "")
        let newline = NSMutableAttributedString(string: "\n")
        var gen = 0
        for (key, value) in representedData {
            gen += 1
            if !General.nullValues.contains(value) {
                if (key == "mine") {
                    let currentString = String.makeBold(text: value)
                    currentString.append(newline)
                    mineString.append(currentString)
                }
                
                else if (key == "type") {
                    let currentSting = NSMutableAttributedString(string: value)
                    currentSting.append(newline)
                    typeString.append(currentSting)
                    
                } else {
                    let currentString = String.formStringWithBoldText(boldText: key.replacingOccurrences(of: ".", with: " ").camelCaseToWords().replacingOccurrences(of: "  ", with: " "), separatorText: ": ", normalText: value)
                    if gen != representedData.count {
                        currentString.append(newline)
                    }
                    infoString.append(currentString)
                }
            } else {
                if gen == representedData.count {
                    // TODO: -if infoString ends with newline -> remove last newline
                }
            }
        }
        resultingString.append(mineString)
        resultingString.append(typeString)
        resultingString.append(infoString)
        return resultingString
    }

}
