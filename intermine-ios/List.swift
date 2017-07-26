//
//  List.swift
//  intermine-ios
//
//  Created by Nadia on 5/14/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation


class List {
    
    private var title: String?
    private var info: String?
    private var size: Int?
    private var type: String? // to be later used as "path"
    private var name: String?
    private var status: String?
    private var authorized: Bool?
    
    init(withTitle: String?, info: String?, size: Int?, type: String?, name: String?, status: String?, authorized: Bool?) {
        self.title = withTitle
        self.info = info
        self.size = size
        self.type = type
        self.name = name
        self.status = status
        self.authorized = authorized
    }
    
    func getName() -> String? {
        return self.name
    }
    
    func getTitle() -> String? {
        // remove underscores
        if let title = self.title {
            return title.replacingOccurrences(of: "_", with: " ")
        }
        return nil
    }
    
    func getInfo() -> String? {
        // TODO: cut to character limit
        if let info = self.info as NSString? {
            if info.length > General.descriptionCharactersLimit {
                let shortened = info.substring(with: NSRange(location: 0, length: info.length > General.descriptionCharactersLimit ? General.descriptionCharactersLimit : info.length))
                return shortened + " ..."
            } else {
                return info as String
            }
        }
        return nil
    }
    
    func getSize() -> Int? {
        return self.size
    }
    
    func isStatusCurrent() -> Bool {
        if let status = self.status {
            return status.uppercased() == "CURRENT"
        }
        return false
    }
    
    func getType() -> String? {
        return self.type
    }
    
    func getValue() -> String? {
        return self.name
    }
    
    func getAuthd() -> Bool {
        if let authd = self.authorized {
            return authd
        } else {
            return false
        }
    }
}
