//
//  ActionCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

protocol ActionCellDelegate: class {
    func actionCellDidTapSearchButton(actionCell: ActionCell)
}

class ActionCell: UITableViewCell {
    
    static let identifier = "ActionCell"
    @IBOutlet weak var searchButton: UIButton?
    
    weak var delegate: ActionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchButton?.setTitle(String.localize("Templates.CTA.Search"), for: .normal)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.delegate?.actionCellDidTapSearchButton(actionCell: self)
    }
    
}
