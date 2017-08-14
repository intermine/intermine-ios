//
//  HeaderView.swift
//  intermine-ios
//
//  Created by Nadia on 8/7/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

enum RefineMode: Int {
    case None = 0
    case All
    case One
}

protocol HeaderViewDelegate: class {
    func headerViewDidTapRefineSearchButton(headerView: HeaderView)
    func headerView(headerView: HeaderView, didSwitchMode: RefineMode)
}

class HeaderView: BaseView {

    @IBOutlet weak var refineSearchButton: BaseButton?
    @IBOutlet weak var modeControl: UISegmentedControl?
    weak var delegate: HeaderViewDelegate?
    
    func configureUI(colorString: String) {
        refineSearchButton?.backgroundColor = UIColor.hexStringToUIColor(hex: colorString)
    }
    
    func configureModeControl(withMode mode: RefineMode, searchableMine: String?) {
        switch mode {
        case .One:
            // one mine is selected, show mode switch
            modeControl?.isHidden = false
            modeControl?.setTitle(String.localize("Search.Refine.SelectedMines"), forSegmentAt: 0)
            modeControl?.setTitle(String.localize("Search.Refine.AllMines"), forSegmentAt: 1)
            break
        default:
            // all mines are searched, hide mode switch
            modeControl?.isHidden = true
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refineSearchButton?.setTitle(String.localize("Search.Refine.CTA"), for: .normal)
    }
    
    @IBAction func refineSearchButtonTapped(_ sender: UIButton) {
        self.delegate?.headerViewDidTapRefineSearchButton(headerView: self)
    }
    
    @IBAction func modeControlSwitched(_ sender: UISegmentedControl) {
        var mode: RefineMode = .None
        switch sender.selectedSegmentIndex {
        case 0:
            mode = .One
            break
        default:
            mode = .All
            break
        }
        self.delegate?.headerView(headerView: self, didSwitchMode: mode)
    }

}
