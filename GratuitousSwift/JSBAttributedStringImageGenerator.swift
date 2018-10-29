//
//  CurrencyImageGenerator.swift
//  Watch Hacker
//
//  Created by Jeffrey Bergier on 8/26/15.
//  Copyright © 2015 Saturday Apps. All rights reserved.
//

import UIKit

class JSBAttributedStringImageGenerator {
    
    func generateImageForAttributedString(_ string: NSAttributedString, scale: CGFloat) -> UIImage? {
        view.attributedText = string
        return self.imageFromView(self.view, scale: scale)
    }
    
    fileprivate let scaleFactor = CGFloat(2.0)
    fileprivate let view = UILabel()
    
    fileprivate func imageFromView(_ inputView: UIView, scale: CGFloat) -> UIImage? {
        inputView.sizeToFit()
        let size = CGSize(width: inputView.bounds.width * scaleFactor, height: inputView.bounds.height * scaleFactor)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return .none }
        context.scaleBy(x: scaleFactor, y: scaleFactor)
        inputView.layer.render(in: context)
        guard let coreImage = context.makeImage() else { return .none }
        UIGraphicsEndImageContext()
        
        return UIImage(cgImage: coreImage, scale: scale, orientation: UIImageOrientation.up)
    }
}
