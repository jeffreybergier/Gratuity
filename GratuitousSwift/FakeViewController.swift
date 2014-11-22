//
//  FakeViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/22/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class FakeViewController: UIViewController {
    //
    //
    //this entire class is needed just to fix the bug where launching in landscape breaks autolayout
    //
    //
    
    var realViewController: TipViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let realViewController = self.realViewController {
            self.presentViewController(realViewController, animated: false, completion: nil)
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}
