//
//  MyTabViewController.swift
//  OnTheMap
//
//  Created by Peter Brooks on 12/10/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import Foundation
import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var addPinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    /********************************************************************************************************
     * The refresh button has been pressed. This routine calls the appropriate VC's "refresh" routine       *
     ********************************************************************************************************/
    @IBAction func refresh(sender: AnyObject) {
        if viewControllers![selectedIndex].isKindOfClass(ListViewController) {
            let controller = selectedViewController as! ListViewController
            controller.refreshList()
        } else {
            let controller = selectedViewController as! MapViewController
            controller.refreshMap()
        }
    }
}
