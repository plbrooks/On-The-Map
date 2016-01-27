//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Peter Brooks on 12/9/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    
    /********************************************************************************************************
     * Set up delegates                                                                                     *
     ********************************************************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
    }
        
    /********************************************************************************************************
     * If no locations show alert                                                                           *
     ********************************************************************************************************/

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalVar.sharedInstance.studentLocations.count
    }
    
    /********************************************************************************************************
     * Show cells                                                                                           *
     ********************************************************************************************************/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListViewCell") as! ListViewCell   // downcasting links in the custom class
        let studentLocation = GlobalVar.sharedInstance.studentLocations[indexPath.row]
        var first = studentLocation.firstName
        var last = studentLocation.lastName
        if (GlobalVar.sharedInstance.test == true && first == Constants.test.changeThisFirstName && last == Constants.test.changeThisLastName) {
            first = Constants.test.useThisFirstName
            last = Constants.test.useThisLastName
        }
        let name = first + " " + last
        cell.label.text = name
        cell.link.text = studentLocation.mediaURL
        return cell
    }
    /********************************************************************************************************
     * Go to detailed view when row is selected                                                             *
     ********************************************************************************************************/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = GlobalVar.sharedInstance.studentLocations[indexPath.row]
        
        /* simple URL string validation - if not begin with "http://", add it to front of string */
        let validatedURL = SharedMethod.insertHTTPIfNeeded(studentLocation.mediaURL)
        
        /* Check for valid URL string. If not, don't show */
        if let url = NSURL(string: validatedURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    /********************************************************************************************************
     * Make the rows alternate color for readability                                                        *
     ********************************************************************************************************/
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 { // row # is not divisible by 2
            let mycolor = UIColor(red: 229.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            cell.layer.backgroundColor = mycolor.CGColor
        } else {
            cell.layer.backgroundColor = UIColor.whiteColor().CGColor
        }
        
        let selection = UIView() as UIView
        selection.layer.borderWidth = 1
        selection.layer.borderColor = UIColor.grayColor().CGColor
        cell.selectedBackgroundView = selection
    }
    
    /********************************************************************************************************
     * Refresh the locations list                                                                           *
     ********************************************************************************************************/
    func refreshList() {
        // get the student locations and create the cells
        SharedMethod.getStudentLocations({(inner: () throws -> Bool) -> Void in    // get the locations
            
            do {
                try inner()
                    /* When the array is complete, we add the annotations to the map. */
                    let studentLocations = GlobalVar.sharedInstance.studentLocations
                    if (studentLocations.count > 0) {  // if there is a location
                        /* When the array is complete, we reload the table data */
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView!.reloadData()
                        }
                    } else {
                        // if here, no student locations in the global student location array so show error message
                        SharedMethod.showAlert(Status.codeIs.noLocations, title: "Error", viewController: self)
                    }
                } catch let error {
                    SharedMethod.showAlert(error, title: "Error", viewController: self)
            }
        })
    }
    
}