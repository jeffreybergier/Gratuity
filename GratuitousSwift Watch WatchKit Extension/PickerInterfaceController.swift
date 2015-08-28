//
//  PickerInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/23/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation
import ObjectiveC.runtime


class PickerInterfaceController: WKInterfaceController {
    
    private var currentBillAmount = 0 {
        didSet {
            let string = NSAttributedString(string: "$\(self.currentBillAmount)", attributes: self.largeValueTextAttributes)
            self.billAmountLabel?.setAttributedText(string)
        }
    }
    private var currentTipPercentage = 0 {
        didSet {
            let string = NSAttributedString(string: "\(self.currentTipPercentage)%", attributes: self.smallValueTextAttributes)
            self.tipPercentageLabel?.setAttributedText(string)
        }
    }

    @IBOutlet private var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private var tipPicker: WKInterfacePicker?
    @IBOutlet private var billPicker: WKInterfacePicker?
    
    private let phoneDelegate = GratuitousWatchConnectivityDelegate()
    
    private let largeValueTextAttributes = GratuitousUIColor.WatchFonts.hugeValueText
    private let smallValueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        print("Beginning Image Load from Raw NSData file for Wheels")
        let dataBeginningTime = NSDate(timeIntervalSinceNow: 0)
        var items = [WKPickerItem]()
        
        // try to get the data
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let dataURL = documentsURL.URLByAppendingPathComponent("dollarAmounts.data")
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
        
        if items.isEmpty == true {
            print("Falling back to text")
            
            for i in 1...500 {
                let item = WKPickerItem()
                item.title = "$\(i)"
                items += [item]
            }
            
            print("Finished Falling Back to Text")
        }
        
        self.billPicker?.setItems(items)
        self.tipPicker?.setItems(items)
        
        let interval = NSDate(timeIntervalSinceNow: 0).timeIntervalSinceDate(dataBeginningTime)
        print("Finished Loading \(items.count) items for Wheels: \(interval) seconds")
    }

    @IBAction func billPickerChanged(value: Int) {
        let billAmount = value
        let tipAmount = Int(round(Double(billAmount) * 0.2))
        let tipPercentage = 20
        self.tipPicker?.setSelectedItemIndex(tipAmount)
        self.currentBillAmount = billAmount
        self.currentTipPercentage = tipPercentage
    }
    
    @IBAction func tipPickerChanged(value: Int) {
        let tipAmount = value
        let billAmount = self.currentBillAmount
        let tipPercentage = Int(round(Double(tipAmount) / Double(billAmount) * 100))
        print("tip percentage: \(tipPercentage)")
        self.currentTipPercentage = tipPercentage
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
