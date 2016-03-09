//
//  StudentData.swift
//  OnTheMap
//
//  Created by Matthew Young on 2/2/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

class StudentData {
    
    static let sharedInstance = StudentData()
    
    var StudentLocationArray: [StudentLocation]?
    
    var currentUserDidPostStudentLocation: Bool {
        let currentFirstName = UdacityClient.sharedInstance.firstNameOfCurrentUser
        let currentLastName = UdacityClient.sharedInstance.lastNameOfCurrentUser
        
        for item in StudentData.sharedInstance.StudentLocationArray! {
            if item.firstName == currentFirstName && item.lastName == currentLastName {
                return true
            }
        }
        return false
    }
    
    var userPostedObjectID: String? {
        let currentFirstName = UdacityClient.sharedInstance.firstNameOfCurrentUser
        let currentLastName = UdacityClient.sharedInstance.lastNameOfCurrentUser
        
        for item in StudentData.sharedInstance.StudentLocationArray! {
            if item.firstName == currentFirstName && item.lastName == currentLastName {
                return item.objectID
            }
        }
        return nil
    }

}
