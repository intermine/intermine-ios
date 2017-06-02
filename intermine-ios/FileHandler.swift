//
//  File.swift
//  intermine-ios
//
//  Created by Nadia on 5/14/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class FileHandler: NSObject {
    
    static let manager: FileManager = FileManager.default
    
    class func getDocumentsDir() -> String? {
        return manager.urls(for: .documentDirectory, in: .userDomainMask).first?.path
    }
    
    class func doesFileExist(fileName: String?) -> Bool {
        guard let fileName = fileName else {
            return false
        }
        if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(fileName)
            if manager.fileExists(atPath: path.path) {
                return true
            }
        }
        return false
    }
    
    class func writeToFile(fileName: String?, contents: String?) {
        guard  let fileName = fileName, let contents = contents else {
            return
        }
        if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(fileName)
            if doesFileExist(fileName: path.path) {
                do {
                    try contents.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                } catch {
                    print("Error writing to a file")
                    print(error)
                }
            } else {
                manager.createFile(atPath: path.path, contents: nil, attributes: nil)
                do {
                    try contents.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                } catch {
                    print("Error writing to a file_1")
                    print(error)
                }

            }
            
        }
    }
    
    class func readFromFile(fileName: String?) -> String? {
        guard let fileName = fileName else {
            return nil
        }
        if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(fileName)
            do {
                let contents = try String(contentsOf: path, encoding: String.Encoding.utf8)
                return contents
            } catch {
                print("Error reading file")
                return nil
            }
        }
        return nil
    }
}
