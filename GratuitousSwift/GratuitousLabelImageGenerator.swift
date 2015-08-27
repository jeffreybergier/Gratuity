//
//  CurrencyImageGenerator.swift
//  Watch Hacker
//
//  Created by Jeffrey Bergier on 8/26/15.
//  Copyright © 2015 Saturday Apps. All rights reserved.
//

import UIKit

class GratuitousLabelImageGenerator {
    
    func generateImageForAttributedString(string: NSAttributedString) -> UIImage? {
        view.attributedText = string
        return self.imageFromView(self.view)
    }
    
    private let view = UILabel()
    
    private func imageFromView(inputView: UIView) -> UIImage? {
        inputView.sizeToFit()
        let rect = inputView.bounds
        
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return .None }
        
        inputView.layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let image = image {
            return image
        } else {
            return .None
        }
    }
}