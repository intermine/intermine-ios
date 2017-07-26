//
//  LaunchViewController.swift
//  intermine-ios
//
//  Created by Nadia on 7/18/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class LaunchViewController: BaseViewController {
    
    @IBOutlet var spinnerContainer: UIView?
    
    class func launchViewController() -> LaunchViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreen") as? LaunchViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerContainer?.layoutIfNeeded()
        if let spinnerContainer = spinnerContainer {
            let spinner = NVActivityIndicatorView(frame: spinnerContainer.bounds, type: .ballSpinFadeLoader, color: Colors.white, padding: self.indicatorPadding())
            spinnerContainer.addSubview(spinner)
            spinner.startAnimating()
        }
    }

    override func indicatorPadding() -> CGFloat {
        if let spinnerContainer = spinnerContainer {
            return BaseView.viewWidth(view: spinnerContainer) / 2.6
        }
        return 0
    }

}
