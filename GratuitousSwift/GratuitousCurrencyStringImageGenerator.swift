//
//  GratuitousCurrencyStringImageGenerator.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/1/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousCurrencyStringImageGenerator {
    
    func generateAllCurrencySymbols() -> [NSURL]? {
        let currencyFormatter = GratuitousCurrencyFormatter(respondToNotifications: false)
        var URLs = [NSURL]()
        for i in 0 ..< 10 {
            if let currencySign = CurrencySign(rawValue: i) {
                currencyFormatter.selectedCurrencySymbol = currencySign
                if let url = self.generateNewCurrencySymbolsFromConfiguredCurrencyFormatter(currencyFormatter) {
                    URLs += [url]
                }
            } else {
                break
            }
        }
        if URLs.isEmpty == false { return URLs } else { return .None }
    }
    
    func generateCurrencySymbolsForCurrencySign(currencySign: CurrencySign) -> (url: NSURL, fileName: String)? {
        let currencyFormatter = GratuitousCurrencyFormatter(respondToNotifications: false)
        currencyFormatter.selectedCurrencySymbol = currencySign
        if let url = self.generateNewCurrencySymbolsFromConfiguredCurrencyFormatter(currencyFormatter),
            let lastPathComponent = url.lastPathComponent {
                return (url: url, fileName: lastPathComponent)
        } else {
            return .None
        }
    }
    
    
    private func generateNewCurrencySymbolsFromConfiguredCurrencyFormatter(currencyFormatter: GratuitousCurrencyFormatter) -> NSURL? {
        //let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
        let valueTextAttributes = GratuitousUIColor.WatchFonts.pickerItemText
        
        let imageGenerator = GratuitousLabelImageGenerator()
        var images = [UIImage]()
        for i in 1 ... 250 {
            let string = NSAttributedString(string: currencyFormatter.currencyFormattedString(i), attributes: valueTextAttributes)
            if let image = imageGenerator.generateImageForAttributedString(string) {
                images += [image]
            }
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(images)
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let dataURL = documentsURL.URLByAppendingPathComponent("\(currencyFormatter.currencyCode)Images.data")
        
        do {
            try data.writeToURL(dataURL, options: .AtomicWrite)
            return dataURL
        } catch {
            NSLog("GratuitousCurrencyStringImageGenerator: Failed to save <\(currencyFormatter.currencyCode)> Currency Images to Disk: \(dataURL.path!)")
            return .None
        }
    }

}
