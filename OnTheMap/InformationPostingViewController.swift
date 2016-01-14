//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Peter Brooks on 11/30/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var whereAreYouStudyingToday: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    /********************************************************************************************************
     * Set up activity indictator as well as text field delegate so can use textFieldShouldReturn method    *
     ********************************************************************************************************/
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.hidden = true
        whereAreYouStudyingToday.delegate = self
    }

    
    /********************************************************************************************************
    * Cancel, go to prior VC                                                                               *
    ********************************************************************************************************/
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(false, completion: nil)
        }
    
    /********************************************************************************************************
     * User has pressed "Find on the Map" button. Go to next VC                                             *
     ********************************************************************************************************/
    @IBAction func findOnMap(sender: AnyObject) {

        processGeo({ (placemark, error) -> Void in  // convert the address entered to a location coordinate
            let coordinates = placemark!.location!.coordinate   // get the coordinates
            // Update the global variable with the coordinates
            GlobalVar.sharedInstance.studentThatIsLoggedIn.coordinates = coordinates
            self.performSegueWithIdentifier("InfoPostingMapSegue", sender: self)
        })
    }
    
    /********************************************************************************************************
    * If the address can be geocoded then get the coordinates else error                                    *
    ********************************************************************************************************/
    func processGeo(getLocCompletionHandler: ((placemark : CLPlacemark?, error : NSError?) -> Void)!) {
        
        let trimmedString = self.whereAreYouStudyingToday.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        GlobalVar.sharedInstance.studentThatIsLoggedIn.location = trimmedString
        
        // housekeeping - dim the map and start the activity indicator while the annotations are being created
        activityIndicatorView.color = UIColor.blackColor()
        activityIndicatorView.startAnimating() // start activity indicator spinner
        activityIndicatorView.hidden = false
        
        CLGeocoder().geocodeAddressString(self.whereAreYouStudyingToday.text!, completionHandler: {(placemarks, error) -> Void in   // called after completes
            if(error == nil) {
                if let placemark = placemarks?[0] {
                    getLocCompletionHandler(placemark: placemark, error: error)
                }
            } else {
                switch (error!.code) {
                case 2:
                    SharedMethod.showAlert(Status.codeIs.noInternet, title: "Error", viewController: self)
                case 8:
                    SharedMethod.showAlert(Status.codeIs.addressNotFound, title: "Error", viewController: self)
                default:
                    SharedMethod.showAlert(Status.codeIs.addressError(code: error!.code, text: error!.localizedDescription), title: "Error", viewController: self)
                }
            }
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
        })
    }
    
    /********************************************************************************************************
     * Return makes keyboard disappear                                                                      *
     ********************************************************************************************************/
    func textFieldShouldReturn(whereAreYouStudyingToday: UITextField) -> Bool // Called when 'return' key pressed
    {
        view.endEditing(true)
        return true;
    }
    
    
}
