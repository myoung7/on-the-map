//
//  FindGeolocation.swift
//  OnTheMap
//
//  Created by Matthew Young on 2/1/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension InformationPostingViewController {
    func getLocationFromStringAndPresentMap(locationString: String) {
        geocoder.geocodeAddressString(locationString) { (placemarkArray, error) in
            guard error == nil else {
                //TODO: Add alert view notifying user.
                print("Error: Location not found.")
                self.finishedLoading()
                self.displayLocationNotFoundAlertView()
                return
            }
            
            guard let placemarkArray = placemarkArray else {
                self.finishedLoading()
                print("Error: Placemark array not found.")
                return
            }
            
            let location = placemarkArray[0]
            
            self.latitude = location.location?.coordinate.latitude
            self.longitude = location.location?.coordinate.longitude
            
            if let city = location.locality {
                if let country = location.country {
                    if let state = location.administrativeArea {
                        self.correctedLocation = "\(city), \(state), \(country)"
                    } else {
                        self.correctedLocation = "\(city), \(country)"
                    }
                } else {
                    self.correctedLocation = "\(city)"
                }
            } else {
                self.correctedLocation = self.locationTextField.text!
            }
            self.finishedLoading()
            self.finishedEnteringLocation = true
            dispatch_async(dispatch_get_main_queue()) {
                self.locationTextField.enabled = false
                self.locationTextField.text = self.correctedLocation
                self.cancelButton.titleLabel?.textColor = UIColor.whiteColor()
                UIView.animateWithDuration(1.5) {
                    let deltaYTop = (-400 / 2208) * self.view.frame.height
                    let deltaYBottom = (600 / 1242) * self.view.frame.height
                    self.blueBackgroundToTopConstraint.constant = deltaYTop
                    self.blueBackgroundToBottomConstraint.constant = deltaYBottom
                    self.acceptButton.setTitle("Submit", forState: .Normal)
                    self.view.layoutIfNeeded()
                }

                UIApplication.sharedApplication().statusBarStyle = .LightContent
                self.setMapViewArea(latitude: self.latitude, longitude: self.longitude)
                self.mediaURLTextField.hidden = false
                self.mediaURLTextField.enabled = true
            }
        }
    }
    
    func setMapViewArea(latitude latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let radius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, radius * 2, radius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotation)
    }
    
    func displayLocationNotFoundAlertView() {
        let alert = UIAlertController(title: "Location Error", message: "Could not find specified location. Please try again.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    

}
