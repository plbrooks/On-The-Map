//
//  Constants
//  OnTheMap
//
//  Created by Peter Brooks on 12/1/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import Foundation

class Constants: NSObject {
    
    /********************************************************************************************************
     * Method and HTTP Body constants                                                                       *
     ********************************************************************************************************/
     
    // documentation: https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
    struct udacity {
        struct method {
            static let POSTaSession =   "https://www.udacity.com/api/session"    // create a session
        }
        struct HTTPBody {
            static let POSTaSession =     "{\"udacity\": {\"username\": \"USERID\", \"password\": \"PASSWORD\"}}"
            static let GETPUblicData =  "https://www.udacity.com/api/users/TOKEN"
        }
    }
   
    // documentation: https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
    struct facebook {
        struct method {
            static let POSTaSession =  "https://www.udacity.com/api/session"    // create a session
        }
        struct HTTPBody {
            static let POSTaSession =   "{\"facebook_mobile\": {\"access_token\": \"TOKEN;\"}}"
        }
    }
    
    // documentation: https://docs.google.com/document/d/1E7JIiRxFR3nBiUUzkKal44l9JkSyqNWvQrNH4pDrOFU/pub?embedded=true
    struct parse {
        static let appID =      "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        struct method {
            static let GETStudentLocations = "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt"    // get list of locations
            static let GETLoginStudentLocationInfo = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22TOKEN%22%7D" // get one student location
            static let POSTLoginStudentLocationInfo =   "https://api.parse.com/1/classes/StudentLocation"
            static let PUTLoginStudentLocationInfo = "https://api.parse.com/1/classes/StudentLocation/TOKEN"   // save one student location
        }
        struct httpBody {
            static let POST = "{\"uniqueKey\": \"KEY\", \"firstName\": \"FIRST\", \"lastName\": \"LAST\",\"mapString\": \"LOCATION\", \"mediaURL\": \"LOCATIONURL\",\"latitude\": LATITUDE, \"longitude\": LONGITUDE}"
            static let PUT = "{\"mapString\": \"LOCATION\", \"mediaURL\": \"LOCATIONURL\",\"latitude\": LATITUDE, \"longitude\": LONGITUDE}"
        }
    }
    

    // Udacity signup URL    
    struct url {
        static let udacitySignup = "https://www.udacity.com/account/auth#!/signup"
    }

    struct test {
        static let login = "davidbowie@ziggy.com"
        static let pw = "stardust"
        static let useThisLogin = "plbrooks@gmail.com"
        static let useThisPW = "2T$gEcRbPWgb@9zYu2vV"
        static let changeThisFirstName = "Peter"
        static let changeThisLastName = "Brooks"
        static let useThisFirstName = "David"
        static let useThisLastName = "Bowie"
    }
    
    
}
