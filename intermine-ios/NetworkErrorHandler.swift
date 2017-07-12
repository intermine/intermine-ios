//
//  NetworkErrorHandler.swift
//  intermine-ios
//
//  Created by Nadia on 7/9/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

enum NetworkErrorType: Int {
    case Unknown = 0
    case ConnectionLost
    case Server
    case Auth
}

class NetworkErrorHandler: NSObject {
    
    class func processError(error: Error) -> NetworkErrorType {
        var errorType = NetworkErrorType.Unknown
        switch error._code {
        case NSURLErrorTimedOut, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
            errorType = NetworkErrorType.ConnectionLost
            break
        case NSURLErrorBadServerResponse, NSURLErrorResourceUnavailable:
            errorType = NetworkErrorType.Server
            break
        case NSURLErrorUserCancelledAuthentication, NSURLErrorUserAuthenticationRequired:
            errorType = NetworkErrorType.Auth
            break
        default:
            break
        }
        return errorType
    }

    class func getErrorMessage(errorType: NetworkErrorType) -> String {
        var message = String.localize("Network.Error.Unknown")
        switch errorType {
        case .ConnectionLost:
            message = String.localize("Network.Error.ConnectionLost")
            break
        case .Server:
            message = String.localize("Network.Error.Server")
            break
        case .Auth:
            message = String.localize("Network.Error.Auth")
            break
        default:
            break
        }
        return message
    }
}
