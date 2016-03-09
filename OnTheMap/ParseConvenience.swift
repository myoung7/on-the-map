//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Matthew Young on 2/1/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import MapKit

extension ParseClient {
    func postStudentLocationInfoToServer(mapString: String, urlString: String, coordinate: CLLocationCoordinate2D, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let jsonBody: [String: AnyObject] = [
            ParameterKeys.UniqueKey: UdacityClient.sharedInstance.userID!,
            ParameterKeys.FirstName: UdacityClient.sharedInstance.firstNameOfCurrentUser!,
            ParameterKeys.LastName: UdacityClient.sharedInstance.lastNameOfCurrentUser!,
            ParameterKeys.MapString: mapString,
            ParameterKeys.MediaURL: urlString,
            ParameterKeys.Latitude: latitude,
            ParameterKeys.Longitude: longitude
        ]
        
        taskForPOSTMethod(Methods.POSTStudentLocation, parameters: [String: AnyObject](), jsonBody: jsonBody) { result, error in
            guard error == nil else {
                print("Error: Could not post data")
                completionHandler(success: false, errorString: "Could not post to server.")
                return
            }
            
            guard let result = result else {
                completionHandler(success: false, errorString: "Could not post to server.")
                return
            }
            
            if let objectID = result[JSONResponseKeys.ObjectID] as? String {
                print(objectID)
                completionHandler(success: true, errorString: nil)
            }
        }
        
    }
    
    func putStudentLocationInfoToServer(mapString: String, urlString: String, coordinate: CLLocationCoordinate2D, objectID: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let jsonBody: [String: AnyObject] = [
            ParameterKeys.UniqueKey: UdacityClient.sharedInstance.userID!,
            ParameterKeys.FirstName: UdacityClient.sharedInstance.firstNameOfCurrentUser!,
            ParameterKeys.LastName: UdacityClient.sharedInstance.lastNameOfCurrentUser!,
            ParameterKeys.MapString: mapString,
            ParameterKeys.MediaURL: urlString,
            ParameterKeys.Latitude: latitude,
            ParameterKeys.Longitude: longitude
        ]
        
        taskForPUTMethod(Methods.PUTStudentLocation, objectID: objectID, jsonBody: jsonBody) { result, error in
            guard error == nil else {
                print("Error: Could not update data")
                completionHandler(success: false, errorString: "Could not update server.")
                return
            }
            
            guard result != nil else {
                completionHandler(success: false, errorString: "Could not update server.")
                return
            }
                completionHandler(success: true, errorString: nil)
        }
    }
}
