//
//  Shared.swift
//  OnTheMap
//
//  Created by Peter Brooks on 12/10/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit

/********************************************************************************************************
 * Common general methods used across VCs                                                               *
 ********************************************************************************************************/
class SharedServices: NSObject {
    static let sharedInstance = SharedServices()    // set up shared instance class
    private override init() {}                      // ensure noone will init
    
    /********************************************************************************************************
     * If URL string does not start with "http" then add it                                                 *
     ********************************************************************************************************/
    func insertHTTPIfNeeded(inURL: String) -> String {
        var outURL = inURL
        if (!inURL.hasPrefix("http")) {
            outURL = "http://" + inURL
        }
        return outURL
    }
   
    /********************************************************************************************************
     * Convert error codes to error messages. Add in variable text as needed.                               *
     ********************************************************************************************************/
    func errorMessage(err: ErrorType) -> String {
        var errMessage = ""
        switch err {
        case Status.codeIs.udacityLogin (let code, let text):
            errMessage = substituteKeyInString(Status.textIs.udacityLogin, key: "STATUSCODE", value: String(code))!
            errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
        case Status.codeIs.facebookLogin (let code, let text):
            errMessage = substituteKeyInString(Status.textIs.facebookLogin, key: "STATUSCODE", value: String(code))!
            errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
        case Status.codeIs.facebookLoginCancelled :
            errMessage = Status.textIs.facebookLoginCancelled
        case Status.codeIs.facebookLoginPermission :
            errMessage = Status.textIs.facebookLoginPermission
        case Status.codeIs.invalidCredentials:
            errMessage = Status.textIs.invalidCredentials
        case Status.codeIs.noDataReturned:
            errMessage = Status.textIs.noDataReturned
        case Status.codeIs.parseProcessing (let code, let text):
            errMessage = substituteKeyInString(Status.textIs.parseProcessing, key: "STATUSCODE", value: String(code))!
            errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
        case Status.codeIs.noLocations:
            errMessage = Status.textIs.noLocations
        case Status.codeIs.JSONConversion (let code, let text):
            errMessage = substituteKeyInString(Status.textIs.JSONConversion, key: "STATUSCODE", value: String(code))!
            errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
        case Status.codeIs.unexpected (let text):
            errMessage = substituteKeyInString(Status.textIs.unexpected, key: "TEXT", value: text)!
        case Status.codeIs.unexpectedWithCode(let code, let text):
            errMessage = substituteKeyInString(Status.textIs.unexpectedWithCode, key: "STATUSCODE", value: String(code))!
            errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
        case Status.codeIs.noInternet:
            errMessage = Status.textIs.noInternet
        case Status.codeIs.logout (let code, let text):
            errMessage = substituteKeyInString(Status.textIs.logout, key: "STATUSCODE", value: String(code))!
            errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
        case Status.codeIs.addressError (let code, let text):
            errMessage = substituteKeyInString(Status.textIs.addressError, key: "STATUSCODE", value: String(code))!
            errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
        case Status.codeIs.addressNotFound:
            errMessage = Status.textIs.addressNotFound
        case Status.codeIs.parseUnauthorized:
            errMessage = Status.textIs.parseUnauthorized
        case Status.codeIs.studentData:
            errMessage = Status.textIs.studentData
        case Status.codeIs.noLocationEntered:
            errMessage = Status.textIs.noLocationEntered
        case Status.codeIs.noLinkEntered:
            errMessage = Status.textIs.noLinkEntered
        case Status.codeIs.invalidLink:
            errMessage = Status.textIs.invalidLink
        case Status.codeIs.studentAdded:
            errMessage = Status.textIs.studentAdded
        case Status.codeIs.studentDoesNotExist:
            errMessage = Status.textIs.studentDoesNotExist
        default:    // no error
            errMessage = Status.textIs.noError
        }
        return errMessage
    }
    
    /********************************************************************************************************
     * Update a string STRING by replacing contents KEY that is found in the string with the contents VALUE *
     ********************************************************************************************************/
    func substituteKeyInString(string: String, key: String, value: String) -> String? {
        if (string.rangeOfString(key) != nil) {
            return string.stringByReplacingOccurrencesOfString(key, withString: value)
        } else {
            return string
        }
    }

    /********************************************************************************************************
     * Show an alert. Message is from mesasge list in the common "Status" file                           *
     ********************************************************************************************************/
    func showAlert (error: ErrorType, title: String, viewController: UIViewController) {
        let message = SharedMethod.errorMessage(error)
        let alertView = UIAlertController(title: title,
            message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        viewController.presentViewController(alertView, animated: true, completion: nil)
    }

}
