//  MapViewController.swift
//  OnTheMap
//
//  Created by Peter Brooks on 12/3/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var annotations = [MKPointAnnotation]()         // array of annotations that are on the map
    var loggedInStudentAnnotations = [MKPointAnnotation]()  // arrary of studentLoggedIn annotations
    
    /********************************************************************************************************
     * Get the first 100 student locations and store in a global array of locations                          *
     ********************************************************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getLocations()
    }
    
    /********************************************************************************************************
     * Set up annotation visuals                                                                            *
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
     * Respond to taps. Open the browser to the URL specified in the annotationViews subtitle property      *
     ********************************************************************************************************/
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            
            /* simple URL string validation - if not begin with "http://", add it to front of string */
            let validatedURL = SharedMethod.insertHTTPIfNeeded(annotationView.annotation!.subtitle!!)
            
            /* Check for valid URL string. If not, don't show */
            if let url = NSURL(string: validatedURL) {
                UIApplication.sharedApplication().openURL(url)
            }

        }
    }

    /********************************************************************************************************
     * 1. Create a list of student locations (getStudentLocations)                                          *
     * 2. Create an annotation for each student location (completion handler                                *
     ********************************************************************************************************/
    func getLocations() {
        
        // housekeeping - dim the map and start the activity indicator while the annotations are being created
        self.mapView.alpha = 0.5 // gray out map until map is rendered
        self.activityIndicatorView.color = UIColor.blackColor()
        self.activityIndicatorView.startAnimating() // start activity indicator spinner
        self.activityIndicatorView.hidden = false
        self.tabBarController!.navigationItem.rightBarButtonItems?.last?.enabled = true // disabled if error
        self.tabBarController!.tabBar.items?.last?.enabled = true                       // disabled if error

        // get the student locations and create the annotations
        SharedMethod.getStudentLocations({(inner: () throws -> Bool) -> Void in    // get the locations
            
            do {
                try inner()
                if (GlobalVar.sharedInstance.studentLocations.count > 0) {      // if there is a location
                    
                    /* When the array is complete, we add the annotations to the map. */
                    for student in GlobalVar.sharedInstance.studentLocations { // for each student in the array
                        // get the info that will be in each annotation view
                        let coordinate = student.coordinates
                        let first = student.firstName
                        let last = student.lastName
                        let mediaURL = student.mediaURL
                        
                        // add the info to the annotation
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        self.annotations.append(annotation)          // add this annotation to the array
                    }
                    self.mapView.addAnnotations(self.annotations)    // show all the annotations on the map
                    /* next 2 lines - enable barbuttonitems, since may be disabled due to prior error       */
                    self.tabBarController!.navigationItem.rightBarButtonItems?.last?.enabled = true
                    self.tabBarController!.tabBar.items?.last?.enabled = true
                } else {
                    // if here, no student locations in the global student location array so show error message
                    SharedMethod.showAlert(Status.codeIs.noLocations, title: "Error", viewController: self)
                    self.stopActivityIndicator()
                }
            } catch let error {
                SharedMethod.showAlert(error, title: "Error", viewController: self)
                self.stopActivityIndicator()
                self.tabBarController!.navigationItem.rightBarButtonItems?.last?.enabled = false
                self.tabBarController!.tabBar.items?.last?.enabled = false
            }
        })
    }

    /********************************************************************************************************
    * Once the map finishes rendering stop the activity indicator                                           *
    ********************************************************************************************************/
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        mapView.alpha = 1.0
        activityIndicatorView.stopAnimating()
        activityIndicatorView.hidden = true
    }
    
    /********************************************************************************************************
     * Refresh the map when the the refresh button is pressed                                               *
     ********************************************************************************************************/
    func refreshMap() {
        mapView.removeAnnotations(annotations)  // delete old annotation views
        annotations.removeAll()                 // clear out annotations array
        GlobalVar.sharedInstance.studentLocations.removeAll()
        getLocations()
        stopActivityIndicator()
    }
    
    /********************************************************************************************************
     * Stop and hide the activity indicator                                                                 *
     ********************************************************************************************************/
    func stopActivityIndicator() {
        mapView.alpha = 1.0
        activityIndicatorView.stopAnimating()
        activityIndicatorView.hidden = true// get locations
    }
}
