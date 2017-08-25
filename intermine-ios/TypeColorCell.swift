//
//  TypeColorCell.swift
//  intermine-ios
//
//  Created by Nadia on 7/21/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

enum CategoryType: String {
    case Gene = "Gene"
    case Protein = "Protein"
    case Publication = "Publication"
    case Organism = "Organism"
    case Interaction = "Interaction"
    case GO = "GO"
    case Nuffink = "Nuffink"
    case All = "All categories"
}

class TypeColorDefine: NSObject {

    class func getSideColor(categoryType: String?) -> UIColor {
        var color = Colors.silver
        if let title = categoryType {
            switch title {
            case CategoryType.Gene.rawValue:
                color = Colors.sushi
                break
            case CategoryType.Protein.rawValue:
                color = Colors.amber
                break
            case CategoryType.Publication.rawValue:
                color = Colors.dodgerBlue
                break
            case CategoryType.Organism.rawValue:
                color = Colors.amaranth
                break
            case CategoryType.Interaction.rawValue:
                color = Colors.orange
                break
            case CategoryType.GO.rawValue:
                color = Colors.seance
                break
            case CategoryType.All.rawValue:
                color = Colors.tamarillo
                break
            default:
                break
            }
        }
        return color
    }
    
    class func getBackgroundColor(categoryType: String?) -> UIColor {
        return getSideColor(categoryType: categoryType)
//        var alpha = 0.1
//        if color == Colors.silver {
//            alpha = 0.3
//        }
//        return color.withAlphaComponent(CGFloat(alpha))
    }

    
}

class TypeColorCell: UITableViewCell {
    
    @IBOutlet weak var separatorView: UIView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        separatorView?.isHidden = false
    }
    
    func hideSeparator() {
        separatorView?.isHidden = true
    }

    func getSideColor(categoryType: String?) -> UIColor {
        return TypeColorDefine.getSideColor(categoryType: categoryType)
    }
    
    func getBackgroundColor(categoryType: String?) -> UIColor {
        return TypeColorDefine.getBackgroundColor(categoryType: categoryType)
    }

}
