//
//  MineModelParser.swift
//  intermine-ios
//
//  Created by Nadia on 5/15/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import SWXMLHash

class MineModelParser: NSObject {
    
    private var xml: XMLIndexer?
    private var viewNames: [String]? = []
    
    override init() {
        self.xml = nil
    }
    
    convenience init(fromFileWithName fileName: String) {
        self.init()
        if let xmlString = FileHandler.readFromFile(fileName: fileName) {
            self.xml = SWXMLHash.lazy(xmlString)
        }
    }
    
    func getViewNames(forType: String) -> [String]? {
        self.findViewsByType(type: forType)
        return self.viewNames
    }
    
    func findViewsByType(type: String) {
        guard let xml = self.xml else {
            return
        }
        
        do {
            let elem = try xml["model"]["class"].withAttribute("name", type).element
            if let extends = elem?.attribute(by: "extends") {
                findViewsByType(type: extends.text)
            } else {
                if let children = elem?.children {
                    for child in children {
                        let desc = child.description
                        if desc.contains("type=\"java.lang.String\"") {
                            let matches = String.findMatches(for: "name=\".*\"", in: desc)
                            if matches.count > 0 {
                                if let match = matches.first {
                                    let removedName = match.replacingOccurrences(of: "name=", with: "")
                                    self.viewNames?.append(removedName.replacingOccurrences(of: "\"", with: ""))
                                }
                            }
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("error parsing xml: \(error)")
        }
    }
    
}
