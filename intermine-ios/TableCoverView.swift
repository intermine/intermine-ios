//
//  TableCoverView.swift
//  intermine-ios
//
//  Created by Nadia on 5/13/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TableCoverView: BaseView {

    @IBOutlet weak var messageLabel: UILabel?
    var spinner: NVActivityIndicatorView?
    
    var upperOffset: CGFloat = 0 {
        didSet {
            spinner = NVActivityIndicatorView(frame: self.indicatorFrame(), type: .ballSpinFadeLoader, color: Colors.apple, padding: self.indicatorPadding())
            hideSpinner()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel?.text = String.localize("General.NothingFound")
        hideLabel()
    }
    
    func showSpinner() {
        if let spinner = self.spinner {
            spinner.frame = self.bounds
            self.addSubview(spinner)
            self.bringSubview(toFront: spinner)
        }
        spinner?.startAnimating()
    }
    
    func hideSpinner() {
        spinner?.stopAnimating()
        if let spinner = self.spinner {
            spinner.removeFromSuperview()
        }
    }
    
    func showLabel() {
        messageLabel?.alpha = 1
    }
    
    func hideLabel() {
        messageLabel?.alpha = 0
    }
    
    // MARK: Private methods
    
    private func indicatorFrame() -> CGRect {
        let viewHeight = BaseView.viewHeight(view: self)
        let indicatorHeight = viewHeight - upperOffset
        let indicatorWidth = BaseView.viewWidth(view: self)
        return CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorHeight)
    }
    
    private func indicatorPadding() -> CGFloat {
        return BaseView.viewWidth(view: self) / 2.5
    }

}
