//
//  GatherLoginData.swift
//  OnTheMap
//
//  Created by Matthew Young on 2/1/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit

extension LoginViewController {
    
    func loginToUdacity() {
        
        let jsonBody = [
            "udacity" : [
                UdacityClient.ParameterKeys.Username: emailTextField.text!,
                UdacityClient.ParameterKeys.Password: passwordTextField.text!
            ]
        ]
        
        guard Reachability.isConnectedToNetwork() else {
            self.finishedLoading()
            self.displayErrorAlertView("No Network Connection. \n Please try again.")
            return
        }
        
        UdacityClient.sharedInstance.taskForPOSTMethod(UdacityClient.Methods.POSTCreateSession, parameters: [String : AnyObject](), jsonBody: jsonBody) { (result, error) -> Void in
            guard error == nil else {
                if error?.code == ErrorCodes.LoginCredentialsInvalid {
                    self.finishedLoading()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayErrorAlertView("Incorrect Email and/or Password. \n Please try again.")
                    }
                } else {
                    self.finishedLoading()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayErrorAlertView("Login failed. \n Please try again.")
                    }
                }
                return
            }
            
            if let sessionDictionary = result[UdacityClient.ParameterKeys.Session] as? [String: AnyObject] {
                if let sessionID = sessionDictionary[UdacityClient.ParameterKeys.SessionID] as? String {
                    UdacityClient.sharedInstance.sessionID = sessionID
                }
            }
            
            if let accountDictionary = result[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] {
                if let userID = accountDictionary[UdacityClient.JSONResponseKeys.UserID] as? String {
                    UdacityClient.sharedInstance.userID = userID
                }
            }
            
            if UdacityClient.sharedInstance.sessionID != nil {
                self.finishedLoading()
                dispatch_async(dispatch_get_main_queue()) {
                    self.completeLogin()
                }
            }
            
        }
        
    }
    
    func checkForValidLogin() -> Bool {
        var loginCredentialsAreValid = true
        var errorText = ""
        
        if emailTextField.text?.characters.count == 0 {
            errorText += "Please type in a valid Email Address.\n"
            loginCredentialsAreValid = false
        }
        if passwordTextField.text?.characters.count == 0 {
            errorText += "Please type in a valid Password."
            loginCredentialsAreValid = false
        }
        
        if loginCredentialsAreValid == false {
            displayErrorAlertView(errorText)
        }
        
        return loginCredentialsAreValid
        
    }
    
    func getFirstAndLastNameFromUserData() {
        UdacityClient.sharedInstance.taskForGETMethod(UdacityClient.Methods.GETPublicUserData, parameters: [String: AnyObject]()) { result, error in
            guard error == nil else {
                print("Error getting public user data.")
                return
            }
            
            if let userDictionary = result[UdacityClient.JSONResponseKeys.User] as? [String: AnyObject] {
                if let firstName = userDictionary[UdacityClient.JSONResponseKeys.FirstName] as? String {
                    UdacityClient.sharedInstance.firstNameOfCurrentUser = firstName
                }
                
                if let lastName = userDictionary[UdacityClient.JSONResponseKeys.LastName] as? String {
                    UdacityClient.sharedInstance.lastNameOfCurrentUser = lastName
                }
            }
        }
    }
    
    func displayErrorAlertView(errorString: String) {
        let alertController = UIAlertController(title: "Login Error", message: errorString, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}
