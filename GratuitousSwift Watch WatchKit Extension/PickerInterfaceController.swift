//
//  PickerInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/23/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation

class PickerInterfaceController: WKInterfaceController {
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    @IBOutlet private var loadingGroup: WKInterfaceGroup?
    @IBOutlet private var mainGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    
    private let watchConnectivityManager = GratuitousWatchConnectivityManager()
    private var interfaceControllerIsConfigured = false
    
    private var items: (billItems: [WKPickerItem], tipItems: [WKPickerItem])? {
        didSet {
            if let items = self.items {
                self.billPicker?.setItems(items.billItems)
                self.tipPicker?.setItems(items.tipItems)
            }
        }
    }
    
    private enum InterfaceState {
        case Loading, Loaded
    }
    
    private var interfaceState: InterfaceState = .Loading {
        didSet {
            switch self.interfaceState {
            case .Loading:
                self.mainGroup?.setHidden(true)
                self.loadingGroup?.setHidden(false)
                self.setTitle("")
            case .Loaded:
                self.mainGroup?.setHidden(false)
                self.loadingGroup?.setHidden(true)
                self.setTitle("Gratuity")
                self.billPicker?.focus()
//                self.animateWithDuration(animationDuration) {
//                }
//                delay(animationDuration) {
//                }
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            // start animating
            self.interfaceState = .Loading
            self.animationImageView?.setImageNamed("gratuityCap4-")
            self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
            
            // configure watch delegate
            self.watchConnectivityManager.delegate = self
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideCurrencySymbolUpdatedOnDisk:", name: "overrideCurrencySymbolUpdatedOnDisk", object: self.dataSource.defaultsManager)
            
            // configure the timer to fix an issue where sometimes the UI would not push to the correct interface controller.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
            dispatch_async(backgroundQueue) {
                self.configurePickerItems()
            }
        }
    }
    
    private func configurePickerItems() {
        if let items = self.setPickerItems(self.dataSource.defaultsManager.overrideCurrencySymbol) {
            dispatch_async(dispatch_get_main_queue()) {
                self.items = items
                self.billPicker?.setSelectedItemIndex(self.dataSource.defaultsManager.billIndexPathRow - 1)
                self.tipPicker?.setSelectedItemIndex(self.dataSource.defaultsManager.tipIndexPathRow - 1)
                self.interfaceState = .Loaded
                self.interfaceControllerIsConfigured = true
            }
        }
    }
    
    @objc private func overrideCurrencySymbolUpdatedOnDisk(notification: NSNotification?) {
        self.interfaceControllerIsConfigured = false
    }
    
    private func setPickerItems(currencySymbol: CurrencySign) -> (billItems: [WKPickerItem], tipItems: [WKPickerItem])? {
        if let url = self.pickerItemsURL(currencySymbol),
            let data = NSData(contentsOfURL: url),
            let items = self.parsePickerItemsFromData(data) {
                self.dataSource.defaultsManager.currencySymbolsNeeded = false
                self.pickerCurrencySign = currencySymbol
                return items
        } else if let fallbackDataURL = NSBundle.mainBundle().URLForResource("fallbackPickerImages", withExtension: "data"),
            let fallbackData = NSData(contentsOfURL: fallbackDataURL),
            let items = self.parsePickerItemsFromData(fallbackData) {
                self.dataSource.defaultsManager.currencySymbolsNeeded = true
                self.pickerCurrencySign = nil
                return items
        } else {
            self.pickerCurrencySign = nil
            self.dataSource.defaultsManager.currencySymbolsNeeded = true
            return .None
        }
    }
    
    private func pickerItemsURL(currency: CurrencySign) -> NSURL? {
        let fileName: String
        switch currency {
        case .Default:
            fileName = "\(self.dataSource.currencyCode)Images.data"
        case .Dollar:
            fileName = "DollarImages.data"
        case .Pound:
            fileName = "PoundImages.data"
        case .Euro:
            fileName = "EuroImages.data"
        case .Yen:
            fileName = "YenImages.data"
        case .None:
            fileName = "NoneImages.data"
        }
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let dataURL = documentsURL.URLByAppendingPathComponent(fileName)
        
        if NSFileManager.defaultManager().fileExistsAtPath(dataURL.path!) == true { return dataURL } else { return .None }
    }
    
    private func parsePickerItemsFromData(data: NSData?) -> (billItems: [WKPickerItem], tipItems: [WKPickerItem])? {
        var billItems = [WKPickerItem]()
        var tipItems = [WKPickerItem]()
        if let data = data,
            let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray {
                for (index, object) in array.enumerate() {
                    if let image = object as? UIImage {
                        let wkImage = WKImage(image: image)
                        if index < 100 {
                            let tipItem = WKPickerItem()
                            tipItem.contentImage = wkImage
                            tipItem.caption = "Tip"
                            tipItems += [tipItem]
                        }
                        let billItem = WKPickerItem()
                        billItem.contentImage = wkImage
                        billItem.caption = "Bill"
                        billItems += [billItem]
                    }
                }
        }
        let returnValue = (billItems: billItems, tipItems: tipItems)
        
        print("\(billItems.count) found")
        if billItems.isEmpty == false { return returnValue } else { return .None }
    }
    
    private var pickerCurrencySign: CurrencySign?
    
    private var currentBillAmount = 0 {
        didSet {
            let string = NSAttributedString(string: self.dataSource.currencyStringFromInteger(self.currentBillAmount), attributes: self.largeValueTextAttributes)
            self.billAmountLabel?.setAttributedText(string)
        }
    }
    private var currentTipPercentage: Double? = 0.0 {
        didSet {
            // this horrible bit of code, updates the picker items if they are available and/or differ from what is set.
            let dataSourceCurrencySign = self.dataSource.defaultsManager.overrideCurrencySymbol
            if let pickerCurrencySign = self.pickerCurrencySign {
                if pickerCurrencySign != dataSourceCurrencySign {
                    let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
                    dispatch_async(backgroundQueue) {
                        //self.configurePickerItems()
                    }
                }
            } else {
                if let _ = self.pickerItemsURL(dataSourceCurrencySign) {
                    let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
                    dispatch_async(backgroundQueue) {
                        //self.configurePickerItems()
                    }
                }
            }
            let string = NSAttributedString(string: self.dataSource.percentStringFromRawDouble(self.currentTipPercentage), attributes: self.smallValueTextAttributes)
            self.tipPercentageLabel?.setAttributedText(string)
        }
    }

    @IBOutlet private var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private var tipPicker: WKInterfacePicker?
    @IBOutlet private var billPicker: WKInterfacePicker?
        
    private let largeValueTextAttributes = GratuitousUIColor.WatchFonts.hugeValueText
    private let smallValueTextAttributes = GratuitousUIColor.WatchFonts.valueText

    @IBAction func billPickerChanged(value: Int) {
        if self.interfaceControllerIsConfigured == true {
            self.dataSource.defaultsManager.billIndexPathRow = value + 1
        }
        
        let billAmount = value + 1
        let suggestTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
        let tipAmount = Int(round(Double(billAmount) * suggestTipPercentage))
        
        let tipIndex = tipAmount - 1
        if tipIndex >= 0 {
            self.tipPicker?.setSelectedItemIndex(tipIndex)
        }
        
        let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        self.currentBillAmount = billAmount + tipAmount
        self.currentTipPercentage = actualTipPercentage
    }
    
    @IBAction func tipPickerChanged(value: Int) {
        if self.interfaceControllerIsConfigured == true {
            self.dataSource.defaultsManager.tipIndexPathRow = value + 1
        }
        
        let billAmount = self.dataSource.defaultsManager.billIndexPathRow
        let tipAmount = value + 1
        let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        self.currentBillAmount = billAmount + tipAmount
        self.currentTipPercentage = actualTipPercentage
    }
    @IBAction private func settingsMenuButtonTapped() {
        self.presentControllerWithName("SettingsInterfaceController", context: .None)
    }
}
