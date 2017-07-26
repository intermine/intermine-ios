//
//  ControllersManager.swift
//  intermine-ios
//
//  Created by Nadia on 7/21/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class ControllersManager: NSObject {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func applicationDidBecomeActive(_ notification: NSNotification) {
        AppManager.sharedManager.canHideVC = true
    }

}
