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
    case Cancelled
}

class NetworkErrorHandler: NSObject {
    
    class func processError(error: Error) -> NetworkErrorType {
        var errorType = NetworkErrorType.Unknown
        switch error._code {
        case NSURLErrorTimedOut, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
            errorType = .ConnectionLost
            break
        case NSURLErrorBadServerResponse, NSURLErrorResourceUnavailable:
            errorType = .Server
            break
        case NSURLErrorUserCancelledAuthentication, NSURLErrorUserAuthenticationRequired:
            errorType = .Auth
            break
        case NSURLErrorCancelled:
            errorType = .Cancelled
        default:
            break
        }
        return errorType
    }

    class func getErrorMessage(errorType: NetworkErrorType) -> String? {
        var message: String? = String.localize("Network.Error.Unknown")
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
        case .Cancelled:
            message = nil
            break
        default:
            break
        }
        return message
    }
}
