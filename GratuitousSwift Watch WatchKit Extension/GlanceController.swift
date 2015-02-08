//
//  GlanceController.swift
//  GratuitousSwift Watch WatchKit Extension
//
//  Created by Jeffrey Bergier on 11/29/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }

}