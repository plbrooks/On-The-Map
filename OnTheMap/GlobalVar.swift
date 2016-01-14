//
//  GlobalVar.swift
//  OnTheMap
//
//  Created by Peter Brooks on 1/13/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import Foundation

class GlobalVar: NSObject {
    
    static let sharedInstance = GlobalVar()    // set up shared instance class
    private override init() {}                      // ensure noone will init


    /**************************************************************************************************************************
    * Custom global vars                                                                                                     *
    *************************************************************************************************************************/
    var studentLocations = [StudentInformation]()       // array of structs of students / locations to be shown on map of Student locations
    var studentThatIsLoggedIn = StudentInformation(jsonStudentData: nil)    // struc of the student that is logged in. Various vars updated from various VCs


}