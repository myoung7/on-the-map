//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/27/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

extension ParseClient {
    struct Constants {
        static let ParseSecureBaseURL = "https://api.parse.com/1/"
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let LimitOfStudentLocations = 100
    }
    
    struct Methods {
        static let GETStudentLocations = "classes/StudentLocation"
        static let POSTStudentLocation = "classes/StudentLocation"
        static let PUTStudentLocation = "classes/StudentLocation/<objectId>"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let UniqueKey = "uniqueKey"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}