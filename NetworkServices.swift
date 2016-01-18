//
//  NetworkServices.swift
//  OnTheMap
//
//  Created by Peter Brooks on 12/1/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import MapKit

/********************************************************************************************************
 * All network methods used across VCs                                                                       *
 ********************************************************************************************************/
class NetworkServices: NSObject {
    static let sharedInstance = NetworkServices()    // set up shared instance class
    private override init() {}                      // ensure noone will init
    
    // used for better readability
    var studentThatIsLoggedIn   = GlobalVar.sharedInstance.studentThatIsLoggedIn
    
    /********************************************************************************************************
     * Login to Udactity. Get the Udacity session id and store the user's account key                       *
     ********************************************************************************************************/
    func udacityLogin(userID: String, userPassword: String, completionHandler: (inner: () throws -> Bool) -> Void) {
        let request = createUdacityLoginRequest(userID, userPassword: userPassword) // create the login request
        let task = performLogin(request) {(inner: () throws -> Bool) -> Void in     // run the session. Save the account key.
            do {
                try inner()                                     // if successful continue else catch the error code
                completionHandler(inner: {true})
            } catch {
                completionHandler(inner: {throw error})
            }
        }
        task.resume()
    }
   
    /********************************************************************************************************
     * Once logged in, use the user's account key to get the user's first and last name. Then,              *
     * store in a global variable                                                                           *
     ********************************************************************************************************/
    func getStudentName(completionHandler: (inner: () throws -> Bool) -> Void) {
        let request = createUdacityGETRequest(studentThatIsLoggedIn.accountKey)     // create the login request
        let task = performLogin(request) {(inner: () throws -> Bool) -> Void in     // run the session. Save the account key
            do {
                try inner()                                               // if successful continue else catch the error code
                completionHandler(inner: {true})
            } catch {
                completionHandler(inner: {throw error})
            }
        }
        task.resume()
    }
 
    /********************************************************************************************************
     * Get the Facebook token that can be used to log in to Udacity                                         *
     ********************************************************************************************************/
    func facebookLogin(accessToken: FBSDKAccessToken, completionHandler: (inner: () throws -> Bool) -> Void) {
        let request = createFacebookHTTPRequest(accessToken)                        // create the login request
        let task = performLogin(request) {(inner: () throws -> Bool) -> Void in     // run the session. Save the account key
            do {
                try inner()                                 // if successful continue else catch the error code
                completionHandler(inner: {true})
            } catch {
                completionHandler(inner: {throw error})
            }
        }
        task.resume()
    }
 
    /********************************************************************************************************
     * Guts of the udacity login processing. Used by udacityLogin, faceboookLogin, and getStudentName to    *
     * ensure common network and error processing
     ********************************************************************************************************/
    func performLogin(request: NSMutableURLRequest, completionHandler: (inner: () throws -> Bool) -> Void) -> NSURLSessionDataTask {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var taskError = Status.codeIs.noError // error that is passed backed to login VC if error is found. Default to "no error"
            
            guard (error == nil)  else {    // an error was returned
                switch(error!.code){
                case -1009:
                    taskError = Status.codeIs.noInternet
                default:
                    taskError = Status.codeIs.udacityLogin(code: error!.code, text: error!.localizedDescription)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw taskError})
                })
                return
            }
            
            let newData = self.convertJSONToDictionary(data!.subdataWithRange(NSMakeRange(5, data!.length - 5)))
            
            guard (newData != nil)  else {  // NO JSON error but an application error was returned via a "status" dictionary
                taskError = Status.codeIs.noDataReturned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw taskError})
                })
                return
            }
            
            guard (newData!.objectForKey("status") == nil)  else {  // an error was returned
                switch(newData!["status"] as! Int) {
                case 403:   // set status error info for invalid credentials
                    taskError = Status.codeIs.invalidCredentials
                default:    // capture status error info for invalid credentials
                    taskError = Status.codeIs.udacityLogin(code: newData!["status"] as! Int, text: newData!["error"] as! String)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw taskError})
                })
                return
            }
        
            // if here all it is good
            if let test = newData?["account"]?["key"] { // if the account key is returned, we are logging in
                let newStudentKey = test as! String
                GlobalVar.sharedInstance.studentThatIsLoggedIn.accountKey = newStudentKey
                self.studentThatIsLoggedIn.accountKey = newStudentKey   // save account key of student who is logging in
            
            } else {   // if here, we already have the account key (logged in), so we want to save the logged in student name
                GlobalVar.sharedInstance.studentThatIsLoggedIn.firstName = newData!["user"]!["first_name"] as! String
                GlobalVar.sharedInstance.studentThatIsLoggedIn.lastName = newData!["user"]!["last_name"] as! String
            }
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(inner: {true})
            })
        }
        return task
    }
    
    /************************************************************************************************************************
    * Logout from Udacity. Under the covers this means to delete the Udacity cookie. Throw if error                         *
    *************************************************************************************************************************/
    func udacityLogout(completionHandler: (inner: () throws -> Bool) -> ()) {
        var taskError = Status.codeIs.noError // set up default
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.udacity.method.POSTaSession)!)
        request.HTTPMethod = "DTE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            guard (error == nil)  else {                            // an error was returned
                switch(error!.code){
                default:
                    taskError = Status.codeIs.logout(code: error!.code, text: error!.localizedDescription)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw taskError})
                })
                return
            }
            let newData = self.convertJSONToDictionary(data!)
            
            guard (newData != nil)  else {                          // newData was nil
               return
            }
            
            guard (newData!.objectForKey("status") == nil)  else {  // NO JSON error but an application error was returned via a "status" dictionary
                switch(newData!["status"] as! Int) {
                default:
                    taskError = Status.codeIs.unexpected(text: "fetching location data")
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw taskError})
                })
                return
            }
        })
        dispatch_async(dispatch_get_main_queue(), {
            completionHandler(inner: {true})
        })
        task.resume()
    }
    
    /********************************************************************************************************
    * Save the logged in student info as a map location via Parse                                           *
    ********************************************************************************************************/
    func saveStudentLocation(completionHandler: (inner: () throws -> Bool) -> ()) {
        saveOrUpdateLocation() {(inner: () throws -> Bool) -> Void in      // save the student info
            do {                                                            // did it work?
                try inner()
                dispatch_async(dispatch_get_main_queue(), {                 // it worked
                    completionHandler(inner: {true})
                })
            } catch let error {                                             // it did not work
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw error})
                })
            }
        }
    }
    
    /********************************************************************************************************
     * Check if the student location exists. If not, add it (call addStudentLocation). If the locatioon      *
     * does exist, update the current location with the new info (call updateStudentLocation)               *
     ********************************************************************************************************/
    func saveOrUpdateLocation(completionHandler: (inner: () throws -> Bool) -> ()) {
        let request = createParseRequest("GET", accountKey: studentThatIsLoggedIn.accountKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil)  else {                            // an error was returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.parseProcessing(code: error!.code, text: error!.localizedDescription)})
                })
                return
            }
            let newData = self.convertJSONToDictionary(data!)
            
            guard (newData != nil)  else {                          // no data returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpected(text: "fetching student location data using Parse")})
                })
                return
            }
            
            guard (newData!.objectForKey("status") == nil)  else {   // NO JSON error but an application error was returned via a "status" dictionary
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpected(text: "fetching student location data using Parse")})
                })
                return
            }
            
            /* if here it is all good  - there is either 1. no results (first time, student has not been added, so we will add) or 2. the student already exists (already added, we will update not add) */
            
            guard (newData!["results"] == nil)  else {              // student results not nil - found
                if (newData?.objectForKey("results")?[0]?["objectID"] == nil) {    // student location not found. "Results" returned but no name so OK to add new location
                    dispatch_async(dispatch_get_main_queue(), {
                        self.addStudentLocation() {(inner: () throws -> Bool) -> Void in     // save the student info
                            do {
                                try inner()
                            }
                            catch let error {
                                dispatch_async(dispatch_get_main_queue(), {
                                    completionHandler(inner: {throw error})
                                })
                            }
                        }
                    })
                } else {                                            // student location. "Results" returned with name
                    let objectId = newData?.objectForKey("results")?[0]?["objectId"] as! String   // check first occurance for valid data
                    dispatch_async(dispatch_get_main_queue(), {
                        self.updateStudentLocation(objectId) {(inner: () throws -> Bool) -> Void in     // update the student info
                            do {
                                try inner()
                                dispatch_async(dispatch_get_main_queue(), {
                                    completionHandler(inner: {true})
                                })
                            }
                            catch let error {
                                dispatch_async(dispatch_get_main_queue(), {
                                    completionHandler(inner: {throw error})
                                })
                            }
                        }
                    })
                }
                return
            }
        }
        task.resume()
    }

    
    /********************************************************************************************************
     * Create a Parse record for the logged in student location                                             *
     ********************************************************************************************************/
    func addStudentLocation(completionHandler: (inner: () throws -> Bool) -> ()) {
        let stud = GlobalVar.sharedInstance.studentThatIsLoggedIn
        let request = createParseRequest("POST",accountKey: stud.accountKey)
        var httpBody = SharedMethod.substituteKeyInString(Constants.parse.httpBody.POST, key: "KEY", value: stud.accountKey)!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "FIRST", value: stud.firstName)!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LAST", value: stud.lastName)!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LOCATIONURL", value: stud.mediaURL)!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LOCATION", value: stud.location)!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LONGITUDE", value: String(stud.coordinates.longitude))!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LATITUDE", value: String(stud.coordinates.latitude))!
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil)  else {                        // an error was returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpectedWithCode(code: error!.code, text: error!.localizedDescription)})
                })
                return
            }
            let newData = self.convertJSONToDictionary(data!)
            
            guard (newData != nil)  else {                          // no data returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.parseProcessing(code: error!.code, text: error!.localizedDescription)
})
                })
                return
            }
            guard (newData!["code"] == nil)  else {                          // status code data returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpectedWithCode(code: newData!["code"] as! Int, text: newData!["error"] as! String)})
                })
                return
            }
            
            guard (newData!.objectForKey("createdAt") != nil)  else {   // NO JSON error but no data returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpected(text: "Parse data fetch")})
                })
                return
            }
            
            /* if here it is all good   */
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(inner: {true})
            })
            return
        }
        task.resume()
    }
    
    /********************************************************************************************************
     * Update the existing Parse record for the logged in student location                                  *
     ********************************************************************************************************/
    func updateStudentLocation(objectId: String, completionHandler: (inner: () throws -> Bool) -> ()) {
        let stud = GlobalVar.sharedInstance.studentThatIsLoggedIn
        let request = createParseRequest("PUT",accountKey: objectId)
        var httpBody = SharedMethod.substituteKeyInString(Constants.parse.httpBody.PUT, key: "LOCATIONURL", value: stud.mediaURL)!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LOCATION", value: stud.location)!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LONGITUDE", value: String(stud.coordinates.longitude))!
        httpBody = SharedMethod.substituteKeyInString(httpBody, key: "LATITUDE", value: String(stud.coordinates.latitude))!
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil)  else {                        // an error was returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.udacityLogin(code: error!.code, text: error!.localizedDescription)
})
                })
                return
            }
            let newData = self.convertJSONToDictionary(data!)
            
            guard (newData != nil)  else {                          // error code returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.parseProcessing(code: error!.code, text: error!.localizedDescription)})
                })
                return
            }
            
            guard (newData!.objectForKey("status") == nil)  else {   // NO JSON error but an application error was returned via a "status" dictionary
                let errorCode = newData!["status"] as! Int
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpectedWithCode(code: errorCode, text: "fetching student location data using Parse")})
                })
                return
            }
            
            guard (newData!["code"] == nil)  else {                          // status code data returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpectedWithCode(code: newData!["code"] as! Int, text: newData!["error"] as! String)})
                })
                return
            }
            
            /* if here it is all good  - there is either no results (first time, student has not been added, so student will be added) or the student already exists (already added, we will update not add) */
            
            guard (newData!["results"] == nil)  else {              // student location not found
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.studentDoesNotExist})
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {true})
            })
            return

        }
        task.resume()
    }

    /********************************************************************************************************
    * Get a list of student location data that will be used to create mapView annotations.                  *
    * Only the data needed to create the annotation will be stored, not all PARSE (JSON) data               *
    ********************************************************************************************************/
    func getStudentLocations(completionHandler: (inner: () throws -> Bool) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.parse.method.GETStudentLocations)!)
        request.addValue(Constants.parse.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.parse.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error?.code != -1009)  else {                        // an error was returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.noInternet})
                })
                return
            }
            
            guard (error == nil)  else {                        // an error was returned
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.parseProcessing(code: error!.code, text: error!.localizedDescription)})
                })
                return
            }
            
            let newData = self.convertJSONToDictionary(data!)
            
            guard (newData != nil)  else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.noLocations})
                })
                return
            }
            
            guard (newData!["error"] as? String != "unauthorized" )  else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.parseUnauthorized})
                })
                return
            }
            
            guard (newData!["results"] != nil)  else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.noLocations})
                })
                return
            }
            
            guard (newData!.objectForKey("status") == nil)  else {   // NO JSON error but an application error was returned via a "status" dictionary
                let errorCode = newData!["status"] as! Int
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(inner: {throw Status.codeIs.unexpectedWithCode(code: errorCode, text: "fetching location data")})
                })
                return
            }
            
            /* if here it is all good */
            let newStudentLocationsUsingJSONData = newData!["results"] as! [[String: AnyObject]]
            let array = self.createAllStudentLocationsArray(newStudentLocationsUsingJSONData)
            GlobalVar.sharedInstance.studentLocations = array    // save to appDelegate var
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(inner: {true})
            })
        }
        task.resume()
    }
    
    /************************************************************************************************************************
    * Create a dictionary of student locations. The dict will ultimately be stored as a global variable in the appDelegate  *
    *************************************************************************************************************************/
    func createAllStudentLocationsArray(newData: [[String: AnyObject]]) -> [StudentInformation] {
        /* cycle through JSON data to get student locations */
        var array = [StudentInformation]()
        for student in newData {
            let newStudentLocation = StudentInformation(jsonStudentData: student)
            
            array.append(newStudentLocation)
        }
        return array
    }

    /************************************************************************************************************************
    * Create the Udacity http request                                                                                        *
    *************************************************************************************************************************/
    func createUdacityLoginRequest(userID: String, userPassword: String) -> NSMutableURLRequest {
        let request = startUniversalHTTPRequest()
        var httpBody = SharedMethod.substituteKeyInString(Constants.udacity.HTTPBody.POSTaSession, key: "USERID", value: userID)
        httpBody = SharedMethod.substituteKeyInString(httpBody!, key: "PASSWORD", value: userPassword)
        request.HTTPBody = httpBody!.dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }
    
    /************************************************************************************************************************
    * Create the Parse http request                                                                                         *
    *************************************************************************************************************************/
    func createParseRequest(method: String, accountKey: String) -> NSMutableURLRequest {
        var newString = ""
        switch method {
        case "GET":
            newString = SharedMethod.substituteKeyInString(Constants.parse.method.GETLoginStudentLocationInfo, key: "TOKEN", value: accountKey)!
        case "POST":
            newString = Constants.parse.method.POSTLoginStudentLocationInfo
        case "PUT":
            newString = SharedMethod.substituteKeyInString(Constants.parse.method.PUTLoginStudentLocationInfo, key: "TOKEN", value: accountKey)!
        default:
            newString = ""
        }
        let request = NSMutableURLRequest(URL: NSURL(string: newString)!)
        request.HTTPMethod = method
        request.addValue(Constants.parse.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.parse.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        if (method == "POST") {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
    
    /************************************************************************************************************************
    * Create the http request                                                                                               *
    *************************************************************************************************************************/
    func createUdacityGETRequest(accountKey: String) -> NSMutableURLRequest {
        let newString = SharedMethod.substituteKeyInString(Constants.udacity.HTTPBody.GETPUblicData, key: "TOKEN", value: accountKey)
        let request = NSMutableURLRequest(URL: NSURL(string: newString!)!)
        return request
    }
    
    /************************************************************************************************************************
    * Create the http request                                                                                               *
    *************************************************************************************************************************/
    func createFacebookHTTPRequest(accessToken: FBSDKAccessToken) -> NSMutableURLRequest {
        let request = startUniversalHTTPRequest()
        let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let httpBody = SharedMethod.substituteKeyInString(Constants.facebook.HTTPBody.POSTaSession, key: "TOKEN", value: fbAccessToken)
        request.HTTPBody = httpBody!.dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }

    
    /************************************************************************************************************************
    * Build the URL and configure the request. Parameters obtained from Constants file                                      *
    *************************************************************************************************************************/
    func startUniversalHTTPRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.udacity.method.POSTaSession)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /************************************************************************************************************************
    * Convert JSON output to a dictionary                                                                                   *
    *************************************************************************************************************************/
    func convertJSONToDictionary(data: NSData) -> NSDictionary? {
        let anyObj: AnyObject?
        do {
            anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        } catch {
            anyObj = nil
        }
        
        return anyObj as? NSDictionary
    }

}
