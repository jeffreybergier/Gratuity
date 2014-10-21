//
//  GratuitousGradientView.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import QuartzCore

class GratuitousGradientView: UIView {
    
    internal let gradient = CAGradientLayer()
    var isUpsideDown:Bool = false {
        didSet {
            self.gradient.colors = [UIColor.clearColor().CGColor, UIColor(red: 29.0/255.0, green: 0, blue: 0, alpha: 1).CGColor]
            //self.gradient.colors = [UIColor.clearColor().CGColor, GratuitousColorSelector.darkBackgroundColor().CGColor]
            //self.gradient.colors = [UIColor.clearColor().CGColor, GratuitousColorSelector.lightBackgroundColor().CGColor]
            //self.gradient.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
        }
    }
    
    internal override init() {
        super.init()
        self.commonInitializer()
    }
    
    internal required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitializer()
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitializer()
    }
    
    internal func commonInitializer() {
        self.backgroundColor = UIColor.clearColor()
        self.gradient.frame = self.bounds
        self.gradient.colors = [UIColor(red: 29.0/255.0, green: 0, blue: 0, alpha: 1).CGColor, UIColor.clearColor().CGColor]
        //self.gradient.colors = [UIColor.blackColor().CGColor, UIColor.whiteColor().CGColor]
        //self.gradient.colors = [GratuitousColorSelector.darkBackgroundColor().CGColor, UIColor.clearColor().CGColor]
        //self.gradient.colors = [GratuitousColorSelector.lightBackgroundColor().CGColor, UIColor.clearColor().CGColor]
        self.layer.insertSublayer(self.gradient, atIndex: 0)
    }
    
    override func layoutSubviews() {
        self.gradient.frame = self.bounds
        super.layoutSubviews()
    }
    
}
