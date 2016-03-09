//
//  ViewController.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/26/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nowLoadingBackgroundView: UIView!
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    @IBAction func tapRecognized(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func signUpForAccountButtonTouchedUpInside() {
        UIApplication.sharedApplication().openURL(NSURL(string: UdacityClient.Constants.UdacitySignUpURL)!)
    }
    
    @IBAction func loginButtonTouchedUpInside(sender: UIButton) {
        if checkForValidLogin() {
            nowLoading()
            loginToUdacity()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer)
        loadingActivityIndicator.hidden = true
    }
    
    func completeLogin() {
        getFirstAndLastNameFromUserData()
        emailTextField.text = ""
        passwordTextField.text = ""
        let controller = storyboard?.instantiateViewControllerWithIdentifier("MapViewTabBarController")
        presentViewController(controller!, animated: true, completion: nil)
    }
    
    func nowLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25, animations: {
                self.nowLoadingBackgroundView.alpha = 0.5
            })
            self.loadingActivityIndicator.hidden = false
            self.loadingActivityIndicator.startAnimating()
        }
    }
    
    func finishedLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25, animations: {
                self.nowLoadingBackgroundView.alpha = 0.0
            })
            self.loadingActivityIndicator.stopAnimating()
        }
    }
    
}

