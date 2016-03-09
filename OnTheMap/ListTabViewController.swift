//
//  ListTabViewController.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/29/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit

class ListTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nowLoadingBackgroundView: UIView!
    @IBOutlet weak var studentLocationTableView: UITableView!
    
    let limitOfLocations = 100
    var dataRefreshSuccessful = false
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        nowLoading()
        UdacityClient.sharedInstance.logOutOfSession { success in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                self.displayLogoutErrorAlertView()
            }
            self.finishedLoading()
        }
    }
    
    @IBAction func addNewLocationButtonPressed(sender: UIBarButtonItem) {
        if StudentData.sharedInstance.currentUserDidPostStudentLocation {
            displayUpdateAlert()
        } else {
            performSegueWithIdentifier("newStudentLocationSegue", sender: self)
        }
    }
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocations()
    }
    
    func getStudentLocations() {
        nowLoading()
        ParseClient.sharedInstance.getLocationData(ParseClient.Constants.LimitOfStudentLocations) { (result, error) -> Void in
            if error != nil {
                print(error?.description)
                self.finishedLoading()
                self.displayErrorAlertView()
                return
            } else {
                StudentData.sharedInstance.StudentLocationArray = result
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentLocationTableView.reloadData()
                }
                self.finishedLoading()
                self.dataRefreshSuccessful = true
            }
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentData.sharedInstance.StudentLocationArray!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OnTheMapCell") as! OnTheMapTableViewCell
        let locationItem = StudentData.sharedInstance.StudentLocationArray![indexPath.row]
        
        cell.nameLabel.text = "\(locationItem.firstName) \(locationItem.lastName)"
        cell.urlLabel.text = locationItem.mediaURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().openURL(NSURL(string: StudentData.sharedInstance.StudentLocationArray![indexPath.row].mediaURL)!)
    }
    
    func nowLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25, animations: {
                self.nowLoadingBackgroundView.alpha = 0.5
            })
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    func finishedLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25, animations: {
                self.nowLoadingBackgroundView.alpha = 0.0
            })
            self.activityIndicator.stopAnimating()
        }
    }
    
    func updateStudentLocation(sender: AnyObject) {
        if let button = sender as? UIButton {
            let controller = storyboard?.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
            print(button.tag)
            controller.currentObjectId = StudentData.sharedInstance.StudentLocationArray![button.tag].objectID
            controller.isCurrentlyUpdatingStudentLocation = true
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "updateStudentLocationSegue" {
            let controller = segue.destinationViewController as! InformationPostingViewController
            controller.currentObjectId = StudentData.sharedInstance.userPostedObjectID
            controller.isCurrentlyUpdatingStudentLocation = true
        }
        
        if segue.identifier == "newStudentLocationSegue" {
            let controller = segue.destinationViewController as! InformationPostingViewController
            controller.isCurrentlyUpdatingStudentLocation = false
        }
    }
    
    func displayErrorAlertView() {
        let alertController = UIAlertController(title: nil, message: "Sorry. There was an error retrieving student data.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayLogoutErrorAlertView() {
        let alertController = UIAlertController(title: nil, message: "Sorry, could not log out of current session. Please try again later.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayUpdateAlert() {
        let alertController = UIAlertController(title: nil, message: "You have already posted a previous Student Location. Would you like to update your previous location or add a new one?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Update", style: .Default, handler: { alert in
            self.performSegueWithIdentifier("updateStudentLocationSegue", sender: self)
        }))
        alertController.addAction(UIAlertAction(title: "New", style: .Default, handler: { alert in
            self.performSegueWithIdentifier("newStudentLocationSegue", sender: self)
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
}
