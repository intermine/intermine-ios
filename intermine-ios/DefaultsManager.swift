//
//  DefaultsManager.swift
//  intermine-ios
//
//  Created by Nadia on 5/23/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class DefaultsManager {
    
    class func storeInDefaults(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    class func fetchFromDefaults(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
}
