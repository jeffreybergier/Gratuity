//
//  PickerInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/23/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation

final class PickerInterfaceController: WKInterfaceController, GratuitousWatchDataSourceDelegate {
    
    private let dataSource = GratuitousWatchDataSource()
    
    @IBOutlet private var loadingGroup: WKInterfaceGroup?
    @IBOutlet private var mainGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    
    private var largeInterfaceUpdateNeeded = true
    private var smallInterfaceUpdateNeeded = true
    private var interfaceControllerConfiguredOnce = false
    
    private var interfaceIdleTimer: NSTimer?
    
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
                self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
                self.mainGroup?.setHidden(true)
                self.loadingGroup?.setHidden(false)
                self.setTitle("")
            case .Loaded:
                self.animationImageView?.stopAnimating()
                self.mainGroup?.setHidden(false)
                self.loadingGroup?.setHidden(true)
                self.setTitle("Gratuity")
                self.billPicker?.focus()
            }
        }
    }
    
    private let largeValueTextAttributes = GratuitousUIColor.WatchFonts.hugeValueText
    private let smallValueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private var pickerCurrencySign: CurrencySign?
    private var currentBillAmount = 0 {
        didSet {
            let string = NSAttributedString(string: self.dataSource.currencyStringFromInteger(self.currentBillAmount), attributes: self.largeValueTextAttributes)
            self.billAmountLabel?.setAttributedText(string)
        }
    }
    private var currentTipPercentage: Double? = 0.0 {
        didSet {
            let string = NSAttributedString(string: self.dataSource.percentStringFromRawDouble(self.currentTipPercentage), attributes: self.smallValueTextAttributes)
            self.tipPercentageLabel?.setAttributedText(string)
        }
    }
    
    @IBOutlet private var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private var tipPicker: WKInterfacePicker?
    @IBOutlet private var billPicker: WKInterfacePicker?
    
    private func resetInterfaceIdleTimer() {
        if let existingTimer = self.interfaceIdleTimer {
            existingTimer.invalidate()
            self.interfaceIdleTimer = nil
        }
        self.interfaceIdleTimer = NSTimer.interfaceIdleTimer(self)
    }
    
    // MARK: Initialize
    
    override func willActivate() {
        super.willActivate()
        self.dataSource.delegate = self
        
        if self.interfaceControllerConfiguredOnce == false {
            self.interfaceControllerConfiguredOnce = true
            
            // configure the menu
            self.addMenuItemWithImageNamed("splitTipMenuIcon", title: PickerInterfaceController.LocalizedString.SplitTipMenuIconLabel, action: "splitTipMenuButtonTapped")
            self.addMenuItemWithImageNamed("settingsMenuIcon", title: PickerInterfaceController.LocalizedString.SettingsMenuIconLabel, action: "settingsMenuButtonTapped")
            
            // start the idle timer
            self.resetInterfaceIdleTimer()
            
            // start animating
            self.animationImageView?.setImageNamed("gratuityCap4-")
            
            // configure the timer to fix an issue where sometimes the UI would not push to the correct interface controller.
            self.configurePickerItems()
        } else {
            // if this is not the first time the view has appeared we need the timer to fire immediately
            self.resetInterfaceIdleTimer()
            self.interfaceIdleTimer?.fire()
        }
    }
    
    private func configurePickerItems() {
        // set the UI into a loading state
        self.interfaceState = .Loading
        
        // tell the timer the interface is loaded
        // sometimes it takes longer to load than the timer allows
        // in those cases it loads twice
        self.largeInterfaceUpdateNeeded = false
        
        // dispatch the background for the long running items read from disk operation
        let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
        dispatch_async(backgroundQueue) {
            if let items = self.accessiblePickerItems(self.dataSource.defaultsManager.overrideCurrencySymbol) {
                // dispatch back to the main queue to do the UI work
                dispatch_async(dispatch_get_main_queue()) {
                    // this operation takes the longest
                    self.items = items
                    self.updateInterfaceLabels()
                }
            }
        }
    }
    
    private func updateInterfaceLabels() {
        self.smallInterfaceUpdateNeeded = true
        // set the text in the UI
        let billAmount: Int
        if self.dataSource.defaultsManager.billIndexPathRow < self.items?.billItems.count {
            billAmount = self.dataSource.defaultsManager.billIndexPathRow
        } else {
            billAmount = self.items?.billItems.count ?? self.dataSource.defaultsManager.billIndexPathRow
        }
        let suggestTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
        let tipAmount = Int(round(Double(billAmount) * suggestTipPercentage))
        let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        self.currentBillAmount = billAmount + tipAmount
        self.currentTipPercentage = actualTipPercentage
        
        // set the billpicker
        self.billPicker?.setSelectedItemIndex(billAmount - 1)
        
        // if there is a manual tip amount set
        if self.dataSource.defaultsManager.tipIndexPathRow != 0 {
            // set the text in the UI
            let tipAmount: Int
            if self.dataSource.defaultsManager.tipIndexPathRow < self.items?.tipItems.count {
                tipAmount = self.dataSource.defaultsManager.tipIndexPathRow
            } else {
                tipAmount = self.items?.tipItems.count ?? self.dataSource.defaultsManager.tipIndexPathRow
            }
            let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
            self.currentBillAmount = billAmount + tipAmount
            self.currentTipPercentage = actualTipPercentage
            
            self.tipPicker?.setSelectedItemIndex(tipAmount - 1)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                // restore the UI state
                self.smallInterfaceUpdateNeeded = false
                self.interfaceState = .Loaded
            }
        } else {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                // restore the ui state
                self.smallInterfaceUpdateNeeded = false
                self.interfaceState = .Loaded
            }
        }

    }
    
    func setLargeInterfaceRefreshNeeded() {
        self.largeInterfaceUpdateNeeded = true
        self.smallInterfaceUpdateNeeded = true
    }
    
    func setSmallInterfaceRefreshNeeded() {
        self.smallInterfaceUpdateNeeded = true
    }
    
    @objc private func interfaceIdleTimerFired(timer: NSTimer?) {
        if self.largeInterfaceUpdateNeeded == true {
            self.configurePickerItems()
        } else if self.smallInterfaceUpdateNeeded == true {
            self.updateInterfaceLabels()
        }
    }
    
    // MARK: Handle Going Away
    
    override func willDisappear() {
        super.willDisappear()
        self.interfaceIdleTimer?.invalidate()
        self.interfaceIdleTimer = nil
    }
    
    // MARK: Handle User Input

    @IBAction func billPickerChanged(value: Int) {
        let billAmount = value + 1
        let suggestTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
        let tipAmount = Int(round(Double(billAmount) * suggestTipPercentage))
        
        
        let tipIndex = tipAmount - 1
        if self.dataSource.defaultsManager.tipIndexPathRow > 0 {
            self.tipPicker?.setSelectedItemIndex(self.dataSource.defaultsManager.tipIndexPathRow - 1)
        } else if tipIndex >= 0 {
            self.tipPicker?.setSelectedItemIndex(tipIndex)
        }
        if self.smallInterfaceUpdateNeeded == false {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.30 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.dataSource.defaultsManager.billIndexPathRow = value + 1
            }
        }
        
        self.resetInterfaceIdleTimer()
        
        let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        self.currentBillAmount = billAmount + tipAmount
        self.currentTipPercentage = actualTipPercentage
        
    }
    
    @IBAction func tipPickerChanged(value: Int) {
        if self.smallInterfaceUpdateNeeded == false {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.dataSource.defaultsManager.tipIndexPathRow = value + 1
            }
        }
        
        self.resetInterfaceIdleTimer()
        
        let billAmount = self.dataSource.defaultsManager.billIndexPathRow
        let tipAmount = value + 1
        let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        self.currentBillAmount = billAmount + tipAmount
        self.currentTipPercentage = actualTipPercentage
        
        self.smallInterfaceUpdateNeeded = false
    }
    
    @objc private func settingsMenuButtonTapped() {
        self.presentControllerWithName("SettingsInterfaceController", context: self.dataSource)
    }
    
    @objc private func splitTipMenuButtonTapped() {
        self.presentControllerWithName("SplitTotalInterfaceController", context: self.dataSource)
    }
    
    // MARK: Handle Loading Picker Items
    
    private func accessiblePickerItems(currencySymbol: CurrencySign) -> (billItems: [WKPickerItem], tipItems: [WKPickerItem])? {
        if let url = self.pickerItemsURL(currencySymbol),
            let data = NSData(contentsOfURL: url),
            let items = self.parsePickerItemsFromData(data) {
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
                            tipItem.caption = PickerInterfaceController.LocalizedString.TipItemPickerCaption
                            tipItems += [tipItem]
                        }
                        let billItem = WKPickerItem()
                        billItem.contentImage = wkImage
                        billItem.caption = PickerInterfaceController.LocalizedString.BillItemPickerCaption
                        billItems += [billItem]
                    }
                }
        }
        let returnValue = (billItems: billItems, tipItems: tipItems)
        
        if billItems.isEmpty == false { return returnValue } else { return .None }
    }
}

extension NSTimer {
    class func interfaceIdleTimer(object: AnyObject) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(5.0, target: object, selector: "interfaceIdleTimerFired:", userInfo: nil, repeats: true)
    }
}
