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
    
    class func stringToDate(dateString: String?) -> NSDate? {
        if let dateString = dateString {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            return dateFormatter.date(from: dateString) as NSDate?
        } else {
            return nil
        }
    }
 }
