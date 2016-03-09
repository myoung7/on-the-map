//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Matthew Young on 2/2/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

extension UdacityClient {
    func logOutOfSession(completionHandler: (success: Bool) -> Void) {
        taskForDELETEMethod { (result, error) -> Void in
            if error != nil {
                completionHandler(success: false)
            }
            if result != nil {
                completionHandler(success: true)
            }
        }
    }
}
