//
//  AppManager.swift
//  intermine-ios
//
//  Created by Nadia on 5/24/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation


class AppManager {
    
    var selectedMine: String = General.defaultMine {
        didSet {
            //
            var info: [String: Any] = [:]
            info = ["mineName": self.selectedMine]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.mineSelected), object: self, userInfo: info)
        }
    }
    
    var shouldBreakLoading = false {
        didSet {
            if self.shouldBreakLoading {
                IntermineAPIClient.cancelAllRequests()
            }
        }
    }
    
    var token: String? = DefaultsManager.fetchFromDefaults(key: DefaultsKeys.token)
    
    // MARK: Shared Instance
    
    static let sharedManager : AppManager = {
        let instance = AppManager()
        return instance
    }()
    
    // MARK: Public method
    
    func selectMine(mineName: String) {
        self.selectedMine = mineName
    }
    
    func retrieveSelectedMine() {
        if let selectedMine = DefaultsManager.fetchFromDefaults(key: DefaultsKeys.selectedMine) {
            self.selectMine(mineName: selectedMine)
        } else {
            self.selectMine(mineName: General.defaultMine)
        }
    }
    
    func updateToken() {
        self.token = DefaultsManager.fetchFromDefaults(key: DefaultsKeys.token)
    }
}

