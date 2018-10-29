//
//  GratuitousAppDelegate+OpenURL.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

extension GratuitousAppDelegate {
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        var attributes = [String : String]()
        attributes["sourceApp"] = sourceApplication
        attributes["URLHost"] = components?.host
        components?.queryItems?.enumerated().forEach() { (index, qItem) in
            attributes["q\(index+1)-\(qItem.name)"] = qItem.value
        }
                
        return true
    }
}
