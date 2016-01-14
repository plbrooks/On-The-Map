//
//  Status.swift
//  OnTheMap
//
//  Created by Peter Brooks on 1/3/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

class Status: NSObject {
    
/********************************************************************************************************
 * various errors that can occur plus variable fields used to create the total error msg                *
 ********************************************************************************************************/
    enum codeIs: ErrorType {
        case noError
        case udacityLogin               (code: Int, text: String)
        case facebookLogin              (code: Int, text: String)
        case facebookLoginCancelled
        case facebookLoginPermission
        case invalidCredentials
        case noDataReturned
        case parseProcessing            (code: Int, text: String)
        case noLocations
        case JSONConversion             (code: Int, text: String)
        case noInternet
        case logout                     (code: Int, text: String)
        case noLinkEntered
        case invalidLink
        case noLocationEntered
        case studentData
        case parseUnauthorized
        case addressNotFound
        case addressError               (code: Int, text: String)
        case unexpected                 (text: String)
        case unexpectedWithCode         (code: Int, text: String)
        case studentAdded
        case studentDoesNotExist
    }

    /********************************************************************************************************
     * text for various errors plus variable fields (CAPS) used to create the total error msg               ß*
     ********************************************************************************************************/
    
    struct textIs {
        static let udacityLogin =               "Oops - error logging in to Udacity. Status code = STATUSCODE description = TEXT"
        static let facebookLogin =              "Oops - error logging in to Facebook. Status code = STATUSCODE description = TEXT"
        static let facebookLoginCancelled =     "Oops - your Facebook login was cancelled by the system. Please try again later"
        static let facebookLoginPermission =    "Oops - Facebook denied permission for you to login to Udacity"
        static let invalidCredentials =         "Oops - UserID / Password combination not found, please re-enter."
        static let parseUnauthorized =          "Oops - your ID is not authorized to access data. Invalid Parse appID and/or key"
        static let noDataReturned =             "Oops - JSON processing error - no data returned. Please try again later."
        static let parseProcessing =            "Oops - Parse processing error. Status code = STATUSCODE description = TEXT"
        static let noLocations =                "Oops - processing error, no existing student locations found. Please check prior error messages or try again later"
        static let JSONConversion =             "Oops - JSON processing error. Status code = STATUSCODE description = TEXT"
        static let noInternet =                 "Oops - the Internet connection appears to be offline please try again later."
        static let logout =                     "Oops - logout error. Status code = STATUSCODE description = TEXT"
        static let unexpected =                 "Oops - Unexpected TEXT error."
        static let unexpectedWithCode =         "Oops - unexpected error. Status code = STATUSCODE description = TEXT"
        static let noLocationEntered =          "Oops - Please enter a location"
        static let studentData =                "Oops - internal error accessing student data. Please retry later"
        static let addressNotFound =            "Oops - address can not be found. Please re-enter."
        static let addressError =               "Oops - error converting the address to a location. Status code = STATUSCODE description = TEXT"
        static let noLinkEntered =              "Oops - please enter a contact link"
        static let invalidLink =                "Oops - invalid link entered, please re-enter"
        static let studentAdded =               "You have been added!"
        static let studentDoesNotExist =        "Student name could not be found"
        static let noError =                    ""

    }
    
}