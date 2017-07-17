//
//  BaseButton.swift
//  intermine-ios
//
//  Created by Nadia on 6/17/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class BaseButton: UIButton {

    override var isEnabled:Bool {
        didSet {
            if isEnabled {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.backgroundColor = Colors.palma
                    self.alpha = 1.0
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.backgroundColor = Colors.gray56
                    self.alpha = 0.5
                })
            }
        }
    }

}
