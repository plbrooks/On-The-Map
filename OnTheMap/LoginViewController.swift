//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Peter Brooks on 11/30/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit
import Foundation

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController,FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginName: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    /********************************************************************************************************
    * General setup plus setup facebook login defaults                                                      *
    ********************************************************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, HTTPMethod: "DELETE")
            deletepermission.startWithCompletionHandler({(connection,result,error)-> Void in
            })
        }
    }
    
    /********************************************************************************************************
     * 1. Login to udacity (udacityLogin)                                                                   *
     * 2. If login OK, get and save in a global variable the logged in student name info (getStudentName)   *
     ********************************************************************************************************/
    @IBAction func udacityLogin(sender: UIButton) {
        SharedMethod.udacityLogin(loginName.text!, userPassword:loginPassword.text!) {(inner: () throws -> Bool) -> Void in
            do {
                try inner() // if successful continue else catch the error code
                SharedMethod.getStudentName() {(inner: () throws -> Bool) -> Void in
                    do {
                        try inner()
                        self.goToMap()
                    } catch let error {
                        SharedMethod.showAlert(error, title: "Error", viewController: self)
                    }
                }
            } catch let error {
                SharedMethod.showAlert(error, title: "Error", viewController: self)
            }
        }
    }
    
    /********************************************************************************************************
     * User need to sign up for Udacity ID. Show the signup URL.                                            *
     ********************************************************************************************************/
    @IBAction func signUp(sender: UIButton) {
        if let url = NSURL(string: Constants.url.udacitySignup) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    /********************************************************************************************************
     * When returning fron the tab bar controller (user has cancelled, logout from Udacity.                 *
     ********************************************************************************************************/
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        SharedMethod.udacityLogout{(inner: () throws -> Bool) -> Void in     // logout from udacity
            do {
                try inner()
            } catch let error as NSError {
                SharedMethod.showAlert(Status.codeIs.unexpectedWithCode(code: error.code, text: error.localizedDescription), title: "Error", viewController: self)
                return
            }
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    /********************************************************************************************************
     * Go to the mapview via a tab bar controller                                                           *
     ********************************************************************************************************/
    func goToMap() {
        dispatch_async(dispatch_get_main_queue(),{
            self.performSegueWithIdentifier("MyTabBarSegue", sender:self)
        })
    }
    
    
    /********************************************************************************************************
     * Facebook login delegate method with various error checks                                             *
     ********************************************************************************************************/
    func loginButton(fbLoginButton: FBSDKLoginButton!, didCompleteWithResult result:
        FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard(error == nil) else {
            SharedMethod.showAlert(Status.codeIs.facebookLogin(code: error.code,text: error.localizedDescription), title: "Error", viewController: self)
            return
        }
        guard(result.isCancelled == false) else {
            SharedMethod.showAlert(Status.codeIs.facebookLoginCancelled, title: "Error", viewController: self)
            return

        }
        guard(result.grantedPermissions.contains("public_profile") == true) else {
            SharedMethod.showAlert(Status.codeIs.facebookLoginPermission, title: "Error", viewController: self)
            return        }
        /* if here it is all good */
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            SharedMethod.facebookLogin(FBSDKAccessToken.currentAccessToken()) {(inner: () throws -> Bool) -> Void in
                do {
                    try inner() // if successful continue else catch the error code
                    SharedMethod.getStudentName() {(inner: () throws -> Bool) -> Void in
                        do {
                            try inner()
                            self.goToMap()
                        } catch {
                            SharedMethod.showAlert(Status.codeIs.studentData, title: "Error", viewController: self)
                        }
                    }
                } catch let error as NSError {
                    SharedMethod.showAlert(Status.codeIs.unexpectedWithCode(code: error.code, text: error.localizedDescription), title: "Error", viewController: self)
                    return                }
            }
        }
    }
    
    /********************************************************************************************************
     * Facebook logout delegate method - required by Facebook                                                                     *
     ********************************************************************************************************/
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
}