//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/26/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//


extension UdacityClient {
    struct Constants {
        static let UdacitySecureBaseURL = "https://www.udacity.com/"
        static let UdacitySignUpURL = "https://www.udacity.com/account/auth#!/signin"
    }
    
    struct ParameterKeys {
        static let Username = "username"
        static let Password = "password"
        static let Session = "session"
        static let SessionID = "id"
    }
    
    struct JSONResponseKeys {
        static let Account = "account"
        static let UserID = "key"
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
    
    struct Methods {
        //Login to Udacity account
        static let POSTCreateSession = "api/session"
        //Gather Public User Data
        static let GETPublicUserData = "api/users/<id>"
        //Logout of current session
        static let DELETELogOutOfSession = "api/session"
    }
}
