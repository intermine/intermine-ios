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
    @IBOutlet weak var favoriteButton: FavoriteButton?
    @IBOutlet weak var colorView: UIView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        favoriteButton?.changeSelectedState(isFavorite: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemUnfavorited(_:)), name: NSNotification.Name(rawValue: Notifications.unfavorited), object: nil)
    }
    
    var typeColor: UIColor? {
        didSet {
            if let typeColor = self.typeColor {
                colorView?.backgroundColor = typeColor
                //contentView.backgroundColor = typeColor
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        guard let data = self.data, let searchId = data.getId() else {
            return
        }

        if data.isFavorited() {
            CacheDataStore.sharedCacheDataStore.unsaveSearchResult(withId: searchId)
        } else {
            CacheDataStore.sharedCacheDataStore.saveSearchResult(searchResult: data)
        }
    }
    
    var representedData: [String:String] = [:] {
        didSet {
            descriptionLabel?.attributedText = self.labelContents(representedData: representedData)
        }
    }
    
    var data: SearchResult? {
        didSet {
            if let data = self.data {
                favoriteButton?.isEnabled = true
                favoriteButton?.isHidden = false
                favoriteButton?.changeSelectedState(isFavorite: data.isFavorited())
                let viewableRepresentation: [String:String] = data.viewableRepresentation()
                descriptionLabel?.attributedText = self.labelContents(representedData: viewableRepresentation)
                if let type = data.getType() {
                    let typeViewBackgroundColor = getBackgroundColor(categoryType: type)
                    colorView?.backgroundColor = typeViewBackgroundColor
                    self.typeViewBackgroundColor = typeViewBackgroundColor
                }
            }
        }
    }
    
    func itemUnfavorited(_ notificaton: NSNotification) {
        guard let data = self.data else {
            return
        }
        
        if let info = notificaton.userInfo, let id = info["id"] as? String, let dataId = data.getId() {
            if dataId == id {
                favoriteButton?.changeSelectedState(isFavorite: false)
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
