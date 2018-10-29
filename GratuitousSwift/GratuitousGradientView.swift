//
//  GratuitousGradientView.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousGradientView: UIView {
    
    internal let gradient = CAGradientLayer()
    internal let gradientColors = [
        GratuitousUIConstant.darkBackgroundColor().cgColor, GratuitousUIConstant.darkBackgroundColor().cgColor,
        GratuitousUIConstant.darkBackgroundColor().withAlphaComponent(0.6).cgColor,
        GratuitousUIConstant.darkBackgroundColor().withAlphaComponent(0.5).cgColor,
        GratuitousUIConstant.darkBackgroundColor().withAlphaComponent(0.4).cgColor
    ]
    
    var isUpsideDown:Bool = false {
        didSet {
            let colorArray = Array(self.gradientColors.reversed())
            self.gradient.colors = colorArray
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitializer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitializer()
    }
    
    fileprivate func commonInitializer() {
        self.backgroundColor = UIColor.clear
        self.gradient.frame = self.bounds
        self.gradient.colors = self.gradientColors
        self.layer.insertSublayer(self.gradient, at: 0)
    }
    
    override func layoutSubviews() {
        self.gradient.frame = self.bounds
        super.layoutSubviews()
    }
}
