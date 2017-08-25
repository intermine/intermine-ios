//
//  ResultsTableViewCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

enum TagType: String {
    case Gene = "Gene"
    case Genes = "Genes"
    case Genomics = "Genomics"
    case Genome = "Genome"
    case Homologue = "Homologue"
    case Homology = "Homology"
    
    case Publication = "Publication"
    case Author = "Author"
    case Literature = "Literature"
    
    case Protein = "Protein"
    case Proteins = "Proteins"
    case ProteinDomain = "ProteinDomain"
    
    case GOAnnotation = "GOAnnotation"
    case GOTerm = "GOTerm"
    
    case Organism = "Organism"
    
    case Interaction = "Interaction"
    case InteractionTerm = "InteractionTerm"
    case InteractionExperiment = "InteractionExperiment"
    case Complex = "Complex"
    case Interactions = "Interactions"
}

class TagColorDefine: NSObject {
    
    class func getTagColor(tagType: String?) -> UIColor {
        var color = Colors.silver
        if let title = tagType {
            switch title {
            case TagType.Gene.rawValue, TagType.Genes.rawValue, TagType.Genomics.rawValue, TagType.Genome.rawValue, TagType.Homologue.rawValue, TagType.Homology.rawValue:
                color = Colors.sushi
                break
            case TagType.Publication.rawValue, TagType.Author.rawValue, TagType.Literature.rawValue:
                color = Colors.dodgerBlue
                break
            case TagType.Protein.rawValue, TagType.Proteins.rawValue, TagType.ProteinDomain.rawValue:
                color = Colors.amber
                break
            case TagType.GOAnnotation.rawValue, TagType.GOTerm.rawValue:
                color = Colors.seance
                break
            case TagType.Organism.rawValue:
                color = Colors.amaranth
                break
            case TagType.Interaction.rawValue, TagType.InteractionTerm.rawValue, TagType.Interactions.rawValue, TagType.InteractionExperiment.rawValue, TagType.Complex.rawValue:
                color = Colors.orange
                break
            default:
                break
            }
        }
        return color
    }
}


class TemplateTableViewCell: UITableViewCell {
    
    static let identifier = "TemplateCell"
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var userImageView: UIImageView?
    @IBOutlet weak var tagsLabel: UILabel?
    @IBOutlet weak var tagsContainerHeight: NSLayoutConstraint?
    
    @IBOutlet var tagViews: [TagView]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView?.image = Icons.user
        tagsLabel?.text = String.localize("Templates.Tags")
        
        if let tagViews = tagViews {
            for tag in tagViews {
                tag.layer.cornerRadius = tag.frame.size.height/2
                tag.clipsToBounds = true
                tag.isHidden = true
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagsContainerHeight?.constant = 30
        tagsLabel?.alpha = 1
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
            
            if let tags = template?.getTags(), let tagViews = tagViews {
                if tags.count == 0 {
                    tagsContainerHeight?.constant = 0
                    tagsLabel?.alpha = 0
                } else {
                    let count = tags.count <= 3 ? tags.count : 3
                    for i in 0..<count {
                        let tagView = tagViews[i]
                        let tag = tags[i]
                        tagView.isHidden = false
                        tagView.templateTag = tag
                    }
                }
            }
            
            titleLabel?.text = template?.getTitle()
            if let template = self.template {
                userImageView?.isHidden = !template.getAuthd()
            }

        }
    }
}
