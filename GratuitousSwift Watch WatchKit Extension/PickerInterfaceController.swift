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
            self.billAmountLabel?.setText("$\(self.currentBillAmount)")
        }
    }
    private var currentTipPercentage = 0 {
        didSet {
            self.tipPercentageLabel?.setText("\(self.currentTipPercentage)%")
        }
    }

    @IBOutlet private var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private var tipPicker: WKInterfacePicker?
    @IBOutlet private var billPicker: WKInterfacePicker?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private var interfaceControllerIsConfigured = false
    private var currencySymbolDidChangeWhileAway = false
    
    private let subtitleTextAttributes = GratuitousUIColor.WatchFonts.subtitleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        print("Beginning Image Loading for Wheels")
        let beginningTime = NSDate(timeIntervalSinceNow: 0)
        
        var imageItems = [WKPickerItem]()
        for i in 1...100 {
            let item = WKPickerItem()
            item.contentImage = WKImage(imageName: "dollarAmounts-\(i)")
            imageItems += [item]
        }
        self.billPicker?.setItems(imageItems)
        self.tipPicker?.setItems(imageItems)

        let interval = NSDate(timeIntervalSinceNow: 0).timeIntervalSinceDate(beginningTime)
        print("Finished Image Loading for Wheels: \(interval) seconds")
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
