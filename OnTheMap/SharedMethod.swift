//
//  SharedMethod.swift
//  OnTheMap
//
//  Created by Peter Brooks on 1/3/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

class SharedMethod {

/********************************************************************************************************
* Shared instance constants used to improve readability in methods                                     *
********************************************************************************************************/

    static let  udacityLogin            =   NetworkServices.sharedInstance.udacityLogin
    static let  udacityLogout           =   NetworkServices.sharedInstance.udacityLogout
    static let  facebookLogin           =   NetworkServices.sharedInstance.facebookLogin
    static let  getStudentLocations     =   NetworkServices.sharedInstance.getStudentLocations
    static let  insertHTTPIfNeeded      =   SharedServices.sharedInstance.insertHTTPIfNeeded
    static let  errorMessage            =   SharedServices.sharedInstance.errorMessage
    static let  showAlert               =   SharedServices.sharedInstance.showAlert
    static let  getStudentName          =   NetworkServices.sharedInstance.getStudentName
    static let  saveStudent             =   NetworkServices.sharedInstance.saveStudentLocation
    static let  substituteKeyInString   =   SharedServices.sharedInstance.substituteKeyInString
    static let  studentThatIsLoggedIn   =   GlobalVar.sharedInstance.studentThatIsLoggedIn
}