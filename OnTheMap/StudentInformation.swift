//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Peter Brooks on 12/3/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import MapKit

/********************************************************************************************************
 * Student struct used across VCs, particularly in custom global variables stored in the app delegate   *
 ********************************************************************************************************/
struct StudentInformation {
    var     accountKey: String                      // the unique key associated with every student
    var     firstName: String                       // student first name
    var     lastName: String                        // student last name
    var     location: String                        // string of the location (e.g. "Boston, MA")
    var     coordinates:    CLLocationCoordinate2D  // coordinates of the location
    var     mediaURL: String                        // user-entered URL
    
    init(jsonStudentData: [String: AnyObject]?) {
        if jsonStudentData != nil {
            accountKey = jsonStudentData?["uniqueKey"] as! String
            firstName = jsonStudentData!["firstName"] as! String
            lastName = jsonStudentData!["lastName"] as! String
            location = jsonStudentData!["mapString"] as! String
            let coord = CLLocationCoordinate2D(latitude: jsonStudentData!["latitude"] as! Double, longitude: jsonStudentData!["longitude"] as! Double)
            coordinates = coord
            mediaURL = jsonStudentData!["mediaURL"] as! String
        } else {
            accountKey = ""
            firstName = ""
            lastName = ""
            location = ""
            let coord = CLLocationCoordinate2D(latitude:0.0, longitude:0.0)
            coordinates = coord
            mediaURL = ""
        }
    }
}
