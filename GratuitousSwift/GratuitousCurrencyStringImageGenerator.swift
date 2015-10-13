//
//  GratuitousCurrencyStringImageGenerator.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/1/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

final class GratuitousCurrencyStringImageGenerator {
        
    func generateCurrencySymbolsForCurrencySign(currencySign: CurrencySign) -> (url: NSURL, fileName: String)? {
        let dataSource = GratuitousiOSDataSource(use: .Temporary)
        if let url = self.generateNewCurrencySymbol(currencySign, fromDataSource: dataSource),
            let lastPathComponent = url.lastPathComponent {
                return (url: url, fileName: lastPathComponent)
        } else {
            return .None
        }
    }
    
    func generateAllCurrencySymbols() -> [(url: NSURL, fileName: String)]? {
        let dataSource = GratuitousiOSDataSource(use: .Temporary)
        var tuples = [(url: NSURL, fileName: String)]()
        for i in 0 ..< 10 {
            if let currencySign = CurrencySign(rawValue: i) {
                if let url = self.generateNewCurrencySymbol(currencySign, fromDataSource: dataSource) {
                    if let lastPathComponent = url.lastPathComponent {
                        tuples += [(url: url, fileName: lastPathComponent)]
                    }
                }
            } else {
                break
            }
        }
        if tuples.isEmpty == false { return tuples } else { return .None }
    }
    
    
    private func generateNewCurrencySymbol(currencySign: CurrencySign, fromDataSource dataSource: GratuitousiOSDataSource) -> NSURL? {
        //let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
        let valueTextAttributes = GratuitousUIColor.WatchFonts.pickerItemText
        
        let imageGenerator = JSBAttributedStringImageGenerator()
        var images = [UIImage]()
        for i in 1 ... 250 {
            let string = NSAttributedString(string: dataSource.currencyFormattedStringWithCurrencySign(currencySign, amount: i), attributes: valueTextAttributes)
            if let image = imageGenerator.generateImageForAttributedString(string, scale: 2.0) {
                images += [image]
            }
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(images)
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let dataURL = documentsURL.URLByAppendingPathComponent("\(dataSource.currencyCode)Images.data")
        
        do {
            try data.writeToURL(dataURL, options: .AtomicWrite)
            return dataURL
        } catch {
            NSLog("GratuitousCurrencyStringImageGenerator: Failed to save <\(dataSource.currencyCode)> Currency Images to Disk: \(dataURL.path!)")
            return .None
        }
    }

}
