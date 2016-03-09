//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Matthew Young on 1/27/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

//typealias resultErrorCompletionHandler = (result: AnyObject!, error: NSError?) -> Void
typealias studentLocationResultsErrorCompletionHandler = (result: [StudentLocation]!, error: NSError?) -> Void

class ParseClient {
    
    static let sharedInstance = ParseClient()
    
    //TODO: Change GET Method
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: resultErrorCompletionHandler) -> NSURLSessionDataTask {
        let urlString = Constants.ParseSecureBaseURL + method + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

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
            self.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        
        task.resume()
        return task
    }
    
    func taskForPOSTMethod(method: String, parameters: [String: AnyObject], jsonBody: [String: AnyObject], completionHandler: resultErrorCompletionHandler) -> NSURLSessionTask {
        let urlString = Constants.ParseSecureBaseURL + method + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                print("There was an Error in taskForPOSTMethod for \(method): \(error)")
                completionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: ErrorCodes.NetworkError, userInfo: [NSLocalizedDescriptionKey: "Network error in taskForGETMethod."]))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Invalid response in taskForPOSTMethod for \(method) with status code: \(response.statusCode)")
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
            
            self.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
    }
    
    func taskForPUTMethod(method: String, objectID: String?, jsonBody: [String: AnyObject], completionHandler: resultErrorCompletionHandler) -> NSURLSessionTask {
        
        var mutatedMethod = method
        
        if method.containsString("<objectId>") {
            mutatedMethod = method.stringByReplacingOccurrencesOfString("<objectId>", withString: objectID!)
        }
        
        let urlString = Constants.ParseSecureBaseURL + mutatedMethod
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                print("There was an Error in taskForPUTMethod for \(method): \(error)")
                completionHandler(result: nil, error: NSError(domain: "taskForPUTMethod", code: ErrorCodes.NetworkError, userInfo: [NSLocalizedDescriptionKey: "Network error in taskForGETMethod."]))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Invalid response in taskForPUTMethod for \(method) with status code: \(response.statusCode)")
                } else if let response = response {
                    print("Invalid response in taskForPUTMethod for \(method) with response: \(response)")
                } else {
                    print("Invalid response in taskForPUTMethod for \(method).")
                }
                completionHandler(result: nil, error: NSError(domain: "taskForPUTMethod", code: ErrorCodes.InvalidServerResponse, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server."]))
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: NSError(domain: "taskForPUTMethod", code: ErrorCodes.DataNotFound, userInfo: nil))
                return
            }
            
            self.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
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
    
    func getLocationData(limit: Int, completionHandler: studentLocationResultsErrorCompletionHandler) {
        let parameters: [String: AnyObject] = [
            ParameterKeys.Limit: limit,
            ParameterKeys.Order: "-updatedAt"
        ]
        let method = Methods.GETStudentLocations
        
        taskForGETMethod(method, parameters: parameters) { (result, error) in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                if let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] {
                    let studentLocations = StudentLocation.studentLocationsFromResults(results)
                    completionHandler(result: studentLocations, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getLocationData parsing", code: ErrorCodes.ParsingDataError, userInfo: [NSLocalizedDescriptionKey: "Could not parse data getLocationData"]))
                }
            }
            
        }
    }
    
}
