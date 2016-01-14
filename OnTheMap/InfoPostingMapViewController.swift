//
//  InformationPostingMapViewController.swift
//  OnTheMap
//
//  Created by Peter Brooks on 12/20/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit
import MapKit

class InfoPostingMapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var contactLink: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var submit: UIButton!
    
    var studentThatIsLoggedIn   = { return GlobalVar.sharedInstance.studentThatIsLoggedIn } // global var

    /********************************************************************************************************
     * Setup up map alpha and actvity indicator. Add annotation to map based on address entered in prior VC *
     ********************************************************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        contactLink.delegate = self
        mapView.alpha = 0.5                                     // gray out map until map is rendered
        activityIndicatorView.color = UIColor.blackColor()      // use black color
        view.bringSubviewToFront(submit)                        // make sure the activity indicator shows
        activityIndicatorView.startAnimating()                  // start activity indicator spinner
        addAnnotationToMap()                                    // add the annotation using global var input
    }
    
    /********************************************************************************************************
     * Cancel, go to prior VC                                                                               *
     ********************************************************************************************************/
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    /********************************************************************************************************
     * If a contact link has been entered, save the link plus all other req'd inof that has been stored in  *
     * studentThatIsLoggedIn into the Parse record                                                          *
     ********************************************************************************************************/
    @IBAction func submit(sender: AnyObject) {
        switch contactLink.text! {
        case "":
            SharedMethod.showAlert(Status.codeIs.noLinkEntered, title: "Error", viewController: self)
        default:
            let trimmedString = contactLink.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (goodURL(trimmedString)) {
                saveLoggedInStudentInfo(trimmedString)
            } else {
                SharedMethod.showAlert(Status.codeIs.invalidLink, title: "Error", viewController: self)
            }
        }
    }
    
    /********************************************************************************************************
     * Set up the map, add the annotation, center the annotation it the middle of the map                   *
     ********************************************************************************************************/
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let coordinates = studentThatIsLoggedIn().coordinates
        let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinates
        mapView.addAnnotation(pointAnnotation)
        mapView.centerCoordinate = coordinates
        mapView.selectAnnotation(pointAnnotation, animated: true)
    }
    
    /********************************************************************************************************
     * Set up the map, add the annotation, center the annotation it the middle of the map                   *
     ********************************************************************************************************/
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    /********************************************************************************************************
     * Once the map is ready to display, change the alpha to 1 and hide the activity indicator              *
     ********************************************************************************************************/
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        mapView.alpha = 1.0
        activityIndicatorView.stopAnimating()
        activityIndicatorView.hidden = true
    }
    
    /********************************************************************************************************
     * Create the annotation using data from the global studentThatIsLoggedIn var                           *
     * Set the map span so not at street level (default for one annotation map                              *
     ********************************************************************************************************/
    func addAnnotationToMap() {
        dispatch_async(dispatch_get_main_queue()) {
            var annotations = [MKPointAnnotation]()     // dictionary of annotations added to the mapview
            let myAnnotation = MKPointAnnotation()      // the single annotation to show
            myAnnotation.coordinate = self.studentThatIsLoggedIn().coordinates
            let first = self.studentThatIsLoggedIn().firstName
            let last = self.studentThatIsLoggedIn().lastName
            myAnnotation.title = ""
            myAnnotation.title = "\(first) \(last)"
            annotations.append(myAnnotation)
            self.mapView.addAnnotations(annotations)
            self.mapView.showAnnotations(annotations, animated: true)
            
            /* perform some map housekeeping */
            let span = MKCoordinateSpanMake(0.1,0.1)    // set reasonable granularity
            let region = MKCoordinateRegion(center: self.studentThatIsLoggedIn().coordinates , span: span ) // center map
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    /********************************************************************************************************
     * Save the new Student info to Parse                                                                   *
     ********************************************************************************************************/
    func saveLoggedInStudentInfo(url: String) {
        GlobalVar.sharedInstance.studentThatIsLoggedIn.mediaURL = url
        SharedMethod.saveStudent() {(inner: () throws -> Bool) -> Void in     // save the student info
            do {
                try inner()
                SharedMethod.showAlert(Status.codeIs.studentAdded, title: "Success", viewController: self)
            } catch let error as NSError {
                switch (error.code) {
                case 7:
                    SharedMethod.showAlert(Status.codeIs.noInternet, title: "Error", viewController: self)
                case 8:
                    SharedMethod.showAlert(Status.codeIs.addressNotFound, title: "Error", viewController: self)
                default:
                    SharedMethod.showAlert(Status.codeIs.addressError(code: error.code, text: error.localizedDescription), title: "Error", viewController: self)
                }
            }
        }
    }
    
    /********************************************************************************************************
     * check if good URL                                                                                    *
     ********************************************************************************************************/
    func goodURL(urlString: String) -> Bool {
        let validURLString = SharedMethod.insertHTTPIfNeeded(urlString)
        let url:NSURL? = NSURL(string: validURLString)    // use optional because some chars in text can cause url to be nil
        if (url != nil && UIApplication.sharedApplication().canOpenURL(url!)) {
            return true
        } else {
            return false
        }
    }
    
    /********************************************************************************************************
     * Return makes keyboard disappear                                                                      *
     ********************************************************************************************************/
    func textFieldShouldReturn(contactLink: UITextField) -> Bool { // called when 'return' key pressed.
        view.endEditing(true)
        return true;
    }


}
