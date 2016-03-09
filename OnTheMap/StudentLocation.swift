//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/27/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

struct StudentLocation {
    var objectID: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    
    init(dictionary: [String: AnyObject]) {
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Float
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Float
    }
    
    static func studentLocationsFromResults(results: [[String: AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        
        for result in results {
            locations.append(StudentLocation(dictionary: result))
        }
        
        return locations
    }
    
}
