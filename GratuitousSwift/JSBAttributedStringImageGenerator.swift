//
//  CurrencyImageGenerator.swift
//  Watch Hacker
//
//  Created by Jeffrey Bergier on 8/26/15.
//  Copyright © 2015 Saturday Apps. All rights reserved.
//

import UIKit

class JSBAttributedStringImageGenerator {
    
    func generateImageForAttributedString(string: NSAttributedString, scale: CGFloat) -> UIImage? {
        view.attributedText = string
        return self.imageFromView(self.view, scale: scale)
    }
    
    private let scaleFactor = CGFloat(2.0)
    private let view = UILabel()
    
    private func imageFromView(inputView: UIView, scale: CGFloat) -> UIImage? {
        inputView.sizeToFit()
        let size = CGSize(width: inputView.bounds.width * scaleFactor, height: inputView.bounds.height * scaleFactor)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return .None }
        CGContextScaleCTM(context, scaleFactor, scaleFactor)
        inputView.layer.renderInContext(context)
        guard let coreImage = CGBitmapContextCreateImage(context) else { return .None }
        UIGraphicsEndImageContext()
        
        return UIImage(CGImage: coreImage, scale: scale, orientation: UIImageOrientation.Up)
    }
}