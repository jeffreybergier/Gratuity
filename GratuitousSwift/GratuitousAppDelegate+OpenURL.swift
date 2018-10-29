//
//  GratuitousAppDelegate+OpenURL.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

extension GratuitousAppDelegate {
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
        
        var attributes = [String : String]()
        attributes["sourceApp"] = sourceApplication
        attributes["URLHost"] = components?.host
        components?.queryItems?.enumerate().forEach() { (index, qItem) in
            attributes["q\(index+1)-\(qItem.name)"] = qItem.value
        }
                
        return true
    }
}
