//
//  NSDate+Methods.swift
//  intermine-ios
//
//  Created by Nadia on 5/7/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

extension NSDate {
    
    class func hasIntervalPassed(lastUpdated: NSDate, timeInterval: Double) -> Bool {
        let currentDate = NSDate()
        let timePassed = lastUpdated.addingTimeInterval(timeInterval)
        let dateComparisionResult: ComparisonResult = currentDate.compare(timePassed as Date)
        switch dateComparisionResult {
        case .orderedDescending:
            // current date is larger or the same as timePassed
            fallthrough
        case .orderedSame:
            return true
        default:
            // current date is smaller than timePassed
            return false
        }
    }
    
    func isGreaterThan(date: NSDate) -> Bool {
        let dateComparisionResult: ComparisonResult = self.compare(date as Date)
        switch dateComparisionResult {
        case .orderedDescending:
            // current date is larger
            fallthrough
        case .orderedSame:
            return true
        default:
            // current date is smaller 
            return false
        }
    }
    
    class func stringToDate(dateString: String) -> NSDate? {
        // should process both Feb-6-2017 and Feb-16-2017
        var stringToProcess = dateString
        if dateString.characters.count == 10 {
            // Feb-6-2017 case, add leading 0 to day
            let mutableString = NSMutableString(string: dateString)
            mutableString.insert("0", at: 4)
            stringToProcess = mutableString as String
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        return dateFormatter.date(from: stringToProcess) as NSDate?
    }
 }
