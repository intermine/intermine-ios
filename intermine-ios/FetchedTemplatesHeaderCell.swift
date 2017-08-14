//
//  FetchedTemplatesHeaderCellTableViewCell.swift
//  intermine-ios
//
//  Created by Nadia on 8/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

protocol FetchedTemplatesHeaderCellDelegate: class {
    func fetchTemplatesHeaderCellDidTapDetailsButton(cell: FetchedTemplatesHeaderCell)
}

class FetchedTemplatesHeaderCell: UITableViewCell {
    
    @IBOutlet weak var paramsLabel: UILabel?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var detailButton: UIButton?
    
    weak var delegate: FetchedTemplatesHeaderCellDelegate?
    
    static let identifier = "FetchedTemplatesHeaderCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countLabel?.alpha = 0.0
        paramsLabel?.alpha = 0.0
        detailButton?.setTitle(String.localize("General.Details"), for: .normal)
    }
    
    var params: String? {
        didSet {
            if let params = self.params {
                paramsLabel?.text = String.localizeWithArg("Templates.Params", arg: params)
                UIView.animate(withDuration: 0.2, animations: {
                    self.paramsLabel?.alpha = 1.0
                })
            }
        }
    }
    
    @IBAction func detailButtonTapped(_ sender: Any) {
        self.delegate?.fetchTemplatesHeaderCellDidTapDetailsButton(cell: self)
    }
    
    var templatesCount: Int? {
        didSet {
            if let count = self.templatesCount {
                countLabel?.text = String.localizeWithArg("Templates.CountLabel", arg: "\(count)")
                UIView.animate(withDuration: 0.2, animations: {
                    self.countLabel?.alpha = 1.0
                })
            }
        }
    }
    
}
