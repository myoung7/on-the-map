//
//  MapTabViewController.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/27/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nowLoadingBackgroundView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var annotationsArray = [MKPointAnnotation]()
    let limitOfLocations = 100
    
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
    
    @IBAction func refreshScreenButtonPressed(sender: UIBarButtonItem) {
        refreshMapData()
    }
    
    @IBAction func addStudentLocationButtonPressed(sender: UIBarButtonItem) {
        if StudentData.sharedInstance.currentUserDidPostStudentLocation {
            displayUpdateAlert()
        } else {
            performSegueWithIdentifier("newStudentLocationSegue", sender: self)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshMapData()
        mapView.delegate = self
    }
    
    func refreshMapData() {
        mapView.removeAnnotations(annotationsArray)
        annotationsArray = []
        nowLoading()
        ParseClient.sharedInstance.getLocationData(limitOfLocations) { (result, error) -> Void in
            if error != nil {
                print(error?.description)
                self.displayErrorAlertView()
                self.finishedLoading()
                return
            } else {
                StudentData.sharedInstance.StudentLocationArray = result
                dispatch_async(dispatch_get_main_queue()) {
                    self.createAnnotationsForMap(StudentData.sharedInstance.StudentLocationArray!)
                    self.mapView.addAnnotations(self.annotationsArray)
                }
                self.finishedLoading()
            }
        }
    }
    
    func createAnnotationsForMap(locationsArray: [StudentLocation]) {
        for item in locationsArray {
            let annotation = MKPointAnnotation()
            let lat = CLLocationDegrees(item.latitude)
            let lon = CLLocationDegrees(item.longitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.title = "\(item.firstName) \(item.lastName)"
            annotation.subtitle = item.mediaURL
            annotationsArray.append(annotation)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.redColor()
            pinView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let urlString = view.annotation?.subtitle! {
                UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
            }
        }
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
    
    func displayLogoutErrorAlertView() {
        let alertController = UIAlertController(title: nil, message: "Sorry, could not log out of current session. Please try again later.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayErrorAlertView() {
        let alertController = UIAlertController(title: nil, message: "Sorry. There was an error retrieving student data.", preferredStyle: .Alert)
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
