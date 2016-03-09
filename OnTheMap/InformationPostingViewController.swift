//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/30/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate{
    
    let geocoder = CLGeocoder()
    
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    var correctedLocation = ""
    var finishedEnteringLocation = false
    var isCurrentlyUpdatingStudentLocation = false
    var currentObjectId: String!
    
    @IBOutlet weak var nowLoadingLabel: UILabel!
    
    @IBOutlet weak var blueBackgroundToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var blueBackgroundToBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var whereAreYouView: UIView!
    @IBOutlet weak var blueBackgroundView: UIView!
    @IBOutlet weak var nowLoadingBlackBackground: UIView!
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func singleTapRecognized(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func acceptButtonPressed(sender: UIButton) {
        if !finishedEnteringLocation {
            nowLoading()
            getLocationFromStringAndPresentMap(locationTextField.text!)
        } else {
            if mediaURLTextField.text?.characters.count > 0 {
                nowLoading()
                if isCurrentlyUpdatingStudentLocation {
                    putStudentLocation()
                } else {
                    postStudentLocation()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isCurrentlyUpdatingStudentLocation {
            for item in StudentData.sharedInstance.StudentLocationArray! {
                if item.objectID == currentObjectId {
                    locationTextField.text = item.mapString
                    mediaURLTextField.text = item.mediaURL
                }
            }
        }
        acceptButton.titleLabel!.text = "Find on the Map"
        mediaURLTextField.hidden = true
        finishedLoading()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    func displayPostErrorAlertView(alertString: String) {
        let alertController = UIAlertController(title: "Student Location Post Error", message: alertString, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayPostSuccessAlertView() {
        var postOrUpdateString = "posted"
        
        if isCurrentlyUpdatingStudentLocation {
            postOrUpdateString = "updated"
        }
        
        let alertController = UIAlertController(title: "Student Location Post Success", message: "Your location was \(postOrUpdateString) successfully!", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Sweet!", style: .Default, handler: { alert -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func nowLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            self.nowLoadingBlackBackground.hidden = false
            self.nowLoadingLabel.hidden = false
            self.loadingActivityIndicator.hidden = false
            self.loadingActivityIndicator.startAnimating()
        }
    }
    
    func finishedLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            self.nowLoadingBlackBackground.hidden = true
            self.nowLoadingLabel.hidden = true
            self.loadingActivityIndicator.hidden = true
        }
    }
    
    func postStudentLocation() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        ParseClient.sharedInstance.postStudentLocationInfoToServer(correctedLocation, urlString: mediaURLTextField.text!, coordinate: coordinate) { success, errorString in
            guard errorString == nil else {
                self.finishedLoading()
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayPostErrorAlertView(errorString!)
                })
                return
            }
            if success {
                self.finishedLoading()
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayPostSuccessAlertView()
                })
            } else {
                self.finishedLoading()
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayPostErrorAlertView(errorString!)
                })
            }
        }
    }
    
    func putStudentLocation() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        ParseClient.sharedInstance.putStudentLocationInfoToServer(correctedLocation, urlString: mediaURLTextField.text!, coordinate: coordinate, objectID: currentObjectId) { success, errorString in
            guard errorString == nil else {
                self.finishedLoading()
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayPostErrorAlertView(errorString!)
                })
                return
            }
            if success {
                self.finishedLoading()
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayPostSuccessAlertView()
                })
            } else {
                self.finishedLoading()
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayPostErrorAlertView(errorString!)
                })
            }
        }
    }
    
}
