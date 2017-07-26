//
//  FetchedTemplateCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class FetchedCell: TypeColorCell {
    
    static let identifier = "FetchedCell"
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var typeView: UIView?
    private var typeViewBackgroundColor: UIColor?
    
    var typeColor: UIColor? {
        didSet {
            if let typeColor = self.typeColor {
                contentView.backgroundColor = typeColor
            }
        }
    }
    
    var representedData: [String:String] = [:] {
        didSet {
            descriptionLabel?.attributedText = self.labelContents(representedData: representedData)
            typeView?.layer.borderWidth = 1
            typeView?.layer.borderColor = Colors.gray56.withAlphaComponent(0.3).cgColor
        }
    }
    
    var data: SearchResult? {
        didSet {
            if let data = self.data {
                let viewableRepresentation: [String:String] = data.viewableRepresentation()
                descriptionLabel?.attributedText = self.labelContents(representedData: viewableRepresentation)
                if let type = data.getType() {
                    let typeViewBackgroundColor = getBackgroundColor(categoryType: type)
                    typeView?.backgroundColor = typeViewBackgroundColor
                    self.typeViewBackgroundColor = typeViewBackgroundColor
                }
            }
        }
    }
    
    private func labelContents(representedData: [String: String]) -> NSMutableAttributedString {
        var infoString = NSMutableAttributedString(string: "")
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
                } else if (key == "type") {
                    let currentSting = NSMutableAttributedString(string: value)
                    currentSting.append(newline)
                    typeString.append(currentSting)
                } else {
                    let currentString = String.formStringWithBoldText(boldText: key.replacingOccurrences(of: ".", with: " ").replacingOccurrences(of: "  ", with: " "), separatorText: ": ", normalText: value)
                    if gen != representedData.count {
                        currentString.append(newline)
                    }
                    infoString.append(currentString)
                }
            } else {
                if gen == representedData.count {
                    if infoString.string.hasSuffix("\n") {
                        infoString = infoString.attributedSubstring(from: NSMakeRange(0, infoString.length - 1)) as! NSMutableAttributedString
                    }
                }
            }
        }
        resultingString.append(mineString)
        resultingString.append(typeString)
        resultingString.append(infoString)
        return resultingString
    }

}
