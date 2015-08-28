//
//  AssetVerificationInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/28/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

class AssetVerificationInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    override func willActivate() {
        super.willActivate()
        
        // start animating
        self.animationImageView?.setImageNamed("gratuityCap4-")
        self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: 10)
        
        // configure the timer to fix an issue where sometimes the UI would not push to the correct interface controller.
        if let context = self.retrieveMainInterfaceControllerContext(self.dataSource.defaultsManager.overrideCurrencySymbol) {
            self.pushControllerWithName("MainInterfaceController", context: context)
        }
    }
    
    func retrieveMainInterfaceControllerContext(currency: CurrencySign) -> [WKPickerItem]? {
        print("Beginning Image Load from Raw NSData file for Wheels")
        let dataBeginningTime = NSDate(timeIntervalSinceNow: 0)
        
        let fileName: String
        switch currency {
        case .Default:
            fileName = "\(self.dataSource.currencyCode)SystemCurrency.data"
        case .Dollar:
            fileName = "DollarCurrency.data"
        case .Pound:
            fileName = "PoundCurrency.data"
        case .Euro:
            fileName = "EuroCurrency.data"
        case .Yen:
            fileName = "YenCurrency.data"
        case .None:
            fileName = "NoneCurrency.data"
        }
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let dataURL = documentsURL.URLByAppendingPathComponent(fileName)
        var items = [WKPickerItem]()
        if let data = NSData(contentsOfURL: dataURL),
            let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray {
                for object in array {
                    if let image = object as? UIImage {
                        let wkImage = WKImage(image: image)
                        let item = WKPickerItem()
                        item.contentImage = wkImage
                        items += [item]
                    }
                }
        }
        let interval = NSDate(timeIntervalSinceNow: 0).timeIntervalSinceDate(dataBeginningTime)
        print("Finished Loading \(items.count) items for Wheels: \(interval) seconds")
        
        if items.isEmpty == false { return items } else { return .None }
    }
    
}