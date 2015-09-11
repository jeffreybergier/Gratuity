//
//  GratuitousCurrencyStringImageGenerator.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/1/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousCurrencyStringImageGenerator {
        
    func generateCurrencySymbolsForCurrencySign(currencySign: CurrencySign) -> (url: NSURL, fileName: String)? {
        let dataSource = GratuitousiOSDataSource(use: .Temporary)
        dataSource.defaultsManager.overrideCurrencySymbol = currencySign
        if let url = self.generateNewCurrencySymbolsFromConfiguredCurrencyFormatter(dataSource),
            let lastPathComponent = url.lastPathComponent {
                return (url: url, fileName: lastPathComponent)
        } else {
            return .None
        }
    }
    
    
    private func generateNewCurrencySymbolsFromConfiguredCurrencyFormatter(dataSource: GratuitousiOSDataSource) -> NSURL? {
        //let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
        let valueTextAttributes = GratuitousUIColor.WatchFonts.pickerItemText
        
        let imageGenerator = GratuitousLabelImageGenerator()
        var images = [UIImage]()
        for i in 1 ... 250 {
            let string = NSAttributedString(string: dataSource.currencyFormattedString(i), attributes: valueTextAttributes)
            if let image = imageGenerator.generateImageForAttributedString(string) {
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
