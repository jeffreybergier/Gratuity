//
//  GratuitousTableView.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/22/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTableView: UITableView {
    
    var userIsScrolling: Bool = false {
        didSet {
            println("GratuitousTableView didSet userIsScrolling: \(self.userIsScrolling)")

        }
    }
    
    var dragging: Bool {
        didSet {
            
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.userIsScrolling = true
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.userIsScrolling = false
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.userIsScrolling = false
    }

}
