//
//  MenuCell.swift
//  intermine-ios
//
//  Created by Nadia on 5/25/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

protocol MenuCellDelegate: class {
    func mineCell(mineCell: MenuCell, didTapButtonWithMineName name: String, withIndex: Int)
}

class MenuCell: UITableViewCell {

    @IBOutlet weak var mineButton: UIButton?
    @IBOutlet weak var checkImageView: UIImageView?
    weak var delegate: MenuCellDelegate?
    
    var index: Int = 0
    
    var mineName: String? {
        didSet {
            mineButton?.setTitle(mineName, for: .normal)
            if let mineName = self.mineName, let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName) {
                mineButton?.backgroundColor = UIColor.hexStringToUIColor(hex: mine.theme)
            }
        }
    }
    
    @IBAction func mineButtonTapped(_ sender: Any) {
        if let mineName = self.mineName {
            DefaultsManager.storeInDefaults(key: DefaultsKeys.selectedMine, value: mineName)
            self.delegate?.mineCell(mineCell: self, didTapButtonWithMineName: mineName, withIndex: self.index)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView?.image = Icons.check
    }
    
    func hideCheck() {
        checkImageView?.isHidden = true
    }
    
    func showCheck() {
        checkImageView?.isHidden = false
    }

}
