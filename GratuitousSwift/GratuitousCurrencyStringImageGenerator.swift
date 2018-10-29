//
//  GratuitousCurrencyStringImageGenerator.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/1/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

final class GratuitousCurrencyStringImageGenerator {
    
    fileprivate let currencyFormatter = GratuitousNumberFormatter(style: .doNotRespondToLocaleChanges)
    
    func generateCurrencySymbolsForCurrencySign(_ currencySign: CurrencySign) -> (url: URL, fileName: String)? {
        if let url = self.generateNewCurrencySymbol(currencySign) {
            return (url: url, fileName: url.lastPathComponent)
        } else {
            return .none
        }
    }
    
    func generateAllCurrencySymbols() -> [(url: URL, fileName: String)]? {
        var tuples = [(url: URL, fileName: String)]()
        for i in 0 ..< 10 {
            if let currencySign = CurrencySign(rawValue: i) {
                if let url = self.generateNewCurrencySymbol(currencySign) {
                    tuples += [(url: url, fileName: url.lastPathComponent)]
                }
            } else {
                break
            }
        }
        if tuples.isEmpty == false { return tuples } else { return .none }
    }
    
    
    fileprivate func generateNewCurrencySymbol(_ currencySign: CurrencySign) -> URL? {
        let valueTextAttributes = GratuitousUIColor.WatchFonts.pickerItemText
        
        let imageGenerator = JSBAttributedStringImageGenerator()
        var images = [UIImage]()
        for i in 1 ... 250 {
            let string = NSAttributedString(string: self.currencyFormatter.currencyFormattedStringWithCurrencySign(currencySign, amount: i), attributes: valueTextAttributes)
            if let image = imageGenerator.generateImageForAttributedString(string, scale: 2.0) {
                images += [image]
            }
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: images)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataURL = documentsURL.appendingPathComponent("\(self.currencyFormatter.currencyNameFromCurrencySign(currencySign))Images.data")
        
        do {
            try data.write(to: dataURL, options: .atomicWrite)
            return dataURL
        } catch {
            log?.error("Failed to save <\(String(describing: self.currencyFormatter.currencySymbol))> Currency Images to Disk: \(dataURL.path)")
            return .none
        }
    }

}
