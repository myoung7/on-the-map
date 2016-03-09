//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/26/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

typealias resultErrorCompletionHandler = (result: AnyObject!, error: NSError?) -> Void

let sharedInstance = UdacityClient()

class UdacityClient {
    
    static let sharedInstance = UdacityClient()
    
    var sessionID: String?
    var userID: String?
    var session: NSURLSession
    
    var firstNameOfCurrentUser: String?
    var lastNameOfCurrentUser: String?
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: resultErrorCompletionHandler) -> NSURLSessionDataTask {
        
        var mutatedMethod = method
        
        if method.containsString("<id>") {
            mutatedMethod = method.stringByReplacingOccurrencesOfString("<id>", withString: userID!)
        }
        
        let urlString = Constants.UdacitySecureBaseURL + mutatedMethod + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                print("There was an Error in taskForGETMethod for \(method): \(error)")
                completionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: ErrorCodes.NetworkError, userInfo: [NSLocalizedDescriptionKey: "Network error in taskForGETMethod."]))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Invalid response in taskForPOSTMethod for \(method) with status code: \(response.statusCode)")
                } else if let response = response {
                    print("Invalid response in taskForGETMethod for \(method) with response: \(response)")
                } else {
                    print("Invalid response in taskForGETMethod for \(method).")
                }
                completionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: ErrorCodes.InvalidServerResponse, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server taskForGETMethod."]))
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: ErrorCodes.DataNotFound, userInfo: [NSLocalizedDescriptionKey: "No data returned taskForGETMethod"]))
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            
        }
        
        task.resume()
        return task
    }

    
    func taskForPOSTMethod(method: String, parameters: [String: AnyObject], jsonBody: [String: AnyObject], completionHandler: resultErrorCompletionHandler) -> NSURLSessionTask {
        let urlString = Constants.UdacitySecureBaseURL + method + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                print("There was an Error in taskForPOSTMethod for \(method): \(error)")
                completionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: ErrorCodes.NetworkError, userInfo: [NSLocalizedDescriptionKey: "Network error in taskForGETMethod."]))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Invalid response in taskForPOSTMethod for \(method) with status code: \(response.statusCode)")
                    if response.statusCode == 403 {
                        completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: ErrorCodes.LoginCredentialsInvalid, userInfo: [NSLocalizedDescriptionKey : "Invalid username or password."]))
                        return
                    }
                } else if let response = response {
                    print("Invalid response in taskForPOSTMethod for \(method) with response: \(response)")
                } else {
                    print("Invalid response in taskForPOSTMethod for \(method).")
                }
                completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: ErrorCodes.InvalidServerResponse, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server."]))
                return
                }
            
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: ErrorCodes.DataNotFound, userInfo: nil))
                return
            }

            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
    }
    
    func taskForDELETEMethod(completionHandler: resultErrorCompletionHandler) -> NSURLSessionTask {
        let method = Methods.DELETELogOutOfSession
        let urlString = Constants.UdacitySecureBaseURL + method
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                print("There was an Error in taskForDELETEMethod for \(method): \(error)")
                completionHandler(result: nil, error: NSError(domain: "taskForDELETEMethod", code: ErrorCodes.NetworkError, userInfo: [NSLocalizedDescriptionKey: "Network error."]))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Invalid response in taskForDELETEMethod for \(method) with status code: \(response.statusCode)")
                    if response.statusCode == 403 {
                        completionHandler(result: nil, error: NSError(domain: "taskForDELETEMethod", code: ErrorCodes.LoginCredentialsInvalid, userInfo: [NSLocalizedDescriptionKey : "Invalid username or password."]))
                        return
                    }
                } else if let response = response {
                    print("Invalid response in taskForDELETEMethod for \(method) with response: \(response)")
                } else {
                    print("Invalid response in taskForDELETEMethod for \(method).")
                }
                completionHandler(result: nil, error: NSError(domain: "taskForDELETEMethod", code: ErrorCodes.InvalidServerResponse, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server."]))
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: NSError(domain: "taskForDELETEMethod", code: ErrorCodes.DataNotFound, userInfo: nil))
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
    }
    
    func escapedParameters(parameters: [String: AnyObject]) -> String {
        var urlParametersArray = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlParametersArray.append(key + "=" + escapedValue!)
        }
        
        return (!urlParametersArray.isEmpty ? "?" : "") + urlParametersArray.joinWithSeparator("&")
    }

    func parseJSONWithCompletionHandler(data: NSData, completionHandler: resultErrorCompletionHandler) {
        var parsedResult: AnyObject!
        let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        if parsedResult == nil {
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
}

