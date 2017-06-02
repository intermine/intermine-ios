//
//  QueryBuilder.swift
//  intermine-ios
//
//  Created by Nadia on 5/16/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class QueryBuilder: NSObject {
    
    private class func formatItNicely(format: String, substrings: [CVarArg]) -> String {
        return String(format: format, arguments: substrings)
    }
    
    private class func buildViewsQuery(views: [String], type: String) -> String? {
        var viewsString = "view=\""
        for i in 0..<views.count {
            var toAdd = "\(type).%@ "
            if i == views.count - 1 {
                toAdd = "\(type).%@\""
            }
            viewsString.append(toAdd)
        }
        let formatted = self.formatItNicely(format: viewsString, substrings: views)
        return formatted
    }
    
    private class func buildConstraintQuery(type: String, viewsQuery: String, value: String) -> String? {
        let queryString = "<query model=\"genomic\" %@ "
        var query = String(format: queryString, viewsQuery)
        query += String(format: "><constraint path=\"%@\"", type)
        query += String(format: " op=\"IN\" value=\"%@\"/></query>", value)
        return query
    }
    
    class func buildQuery(views: [String], type: String, value: String) -> String? {
        if let viewsQuery = QueryBuilder.buildViewsQuery(views: views, type: type) {
            return QueryBuilder.buildConstraintQuery(type: type, viewsQuery: viewsQuery, value: value)
        }
        return nil
    }
    
}
