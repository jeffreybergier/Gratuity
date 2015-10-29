//
//  PickerInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/23/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit

final class PickerInterfaceController: WKInterfaceController {
    
    private var applicationPreferences: GratuitousUserDefaults {
        get { return GratuitousWatchApplicationPreferences.sharedInstance.preferences }
        set {
            GratuitousWatchApplicationPreferences.sharedInstance.preferencesSetLocally = newValue
        }
    }
    private let currencyFormatter = GratuitousNumberFormatter(style: .RespondsToLocaleChanges)
    
    @IBOutlet private var loadingGroup: WKInterfaceGroup?
    @IBOutlet private var mainGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    @IBOutlet private var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private var tipPicker: WKInterfacePicker?
    @IBOutlet private var billPicker: WKInterfacePicker?
    
    private var largeInterfaceUpdateNeeded = false
    private var smallInterfaceUpdateNeeded = false
    private var interfaceControllerConfiguredOnce = false
    
    private var interfaceIdleTimer: NSTimer?
    
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
                self.setTitle(LocalizedString.InterfaceTitle)
                self.billPicker?.focus()
            }
        }
    }
    
    private let largeValueTextAttributes = GratuitousUIColor.WatchFonts.hugeValueText
    private let smallValueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    
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
        self.updateUserActivity(HandoffTypes.MainTipInterface.rawValue, userInfo: ["string":"string"], webpageURL: .None)
        
        if self.interfaceControllerConfiguredOnce == false {
            self.interfaceControllerConfiguredOnce = true
            // configure notifications
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignDidChange:", name: NSCurrentLocaleDidChangeNotification, object: .None)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignDidChange:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: .None)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "billTipValueChangeByRemote:", name: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote, object: .None)
            
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
            if let items = self.accessiblePickerItems(self.applicationPreferences.overrideCurrencySymbol) {
                // dispatch back to the main queue to do the UI work
                dispatch_async(dispatch_get_main_queue()) {
                    // this operation takes the longest
                    self.billPicker?.setItems(items.billItems)
                    self.tipPicker?.setItems(items.tipItems)
                    self.updateBillPicker()
                    self.updateTipPicker()
                    self.updateBigLabels()
                    self.interfaceState = .Loaded
                }
            }
        }
    }
    
    var billPickerUpdatedProgrammatically = false
    private func updateBillPicker() {
        self.billPickerUpdatedProgrammatically = true
        let c = Calculations(preferences: self.applicationPreferences)
        self.billPicker?.setSelectedItemIndex(c.billAmount - 1)
    }
    
    var tipPickerUpdatedProgrammatically = false
    private func updateTipPicker() {
        self.tipPickerUpdatedProgrammatically = true
        let c = Calculations(preferences: self.applicationPreferences)
        self.tipPicker?.setSelectedItemIndex(c.tipAmount - 1)
    }
    
    private func updateBigLabels() {
        let c = Calculations(preferences: self.applicationPreferences)
        let billAmountString = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.applicationPreferences.overrideCurrencySymbol, amount: c.totalAmount)
        let largeLabelString = NSAttributedString(string: billAmountString, attributes: self.largeValueTextAttributes)
        let tipPercentageString = "\(c.tipPercentage)\(self.currencyFormatter.percentSymbol)"
        let smallLabelString = NSAttributedString(string: tipPercentageString, attributes: self.smallValueTextAttributes)
        self.billAmountLabel?.setAttributedText(largeLabelString)
        self.tipPercentageLabel?.setAttributedText(smallLabelString)
    }
    
    // MARK: Handle Going Away
    
    override func willDisappear() {
        super.willDisappear()
        self.invalidateUserActivity()
        self.interfaceIdleTimer?.invalidate()
        self.interfaceIdleTimer = nil
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Handle User Input

    @IBAction func billPickerChanged(value: Int) {
        if self.billPickerUpdatedProgrammatically == false {
            self.applicationPreferences.billIndexPathRow = value + 1
            self.applicationPreferences.tipIndexPathRow = 0
            self.updateBigLabels()
            self.updateTipPicker()
        }
        self.resetInterfaceIdleTimer()
        self.billPickerUpdatedProgrammatically = false
    }
    
    @IBAction func tipPickerChanged(value: Int) {
        if self.tipPickerUpdatedProgrammatically == false {
            self.applicationPreferences.tipIndexPathRow = value + 1
            self.updateBigLabels()
        }
        self.resetInterfaceIdleTimer()
        self.tipPickerUpdatedProgrammatically = false
    }
    
    @objc private func settingsMenuButtonTapped() {
        self.presentControllerWithName("SettingsInterfaceController", context: .None)
    }
    
    @objc private func splitTipMenuButtonTapped() {
        if self.applicationPreferences.splitBillPurchased == true {
            self.presentControllerWithName("SplitTotalInterfaceController", context: .None)
        } else {
            self.presentControllerWithName("SplitBillPurchaseInterfaceController", context: .None)
        }
    }
    
    // MARK: Handle External UI Updates
    
    @objc private func currencySignDidChange(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currencyFormatter.locale = NSLocale.currentLocale()
            self.setLargeInterfaceRefreshNeeded()
        }
    }
    
    @objc private func billTipValueChangeByRemote(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.setSmallInterfaceRefreshNeeded()
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
            self.largeInterfaceUpdateNeeded = false
            self.configurePickerItems()
        } else if self.smallInterfaceUpdateNeeded == true {
            self.smallInterfaceUpdateNeeded = false
            self.updateBigLabels()
            self.updateTipPicker()
            self.updateBillPicker()
        }
    }
    
    // MARK: Handle Loading Picker Items
    
    private func accessiblePickerItems(currencySymbol: CurrencySign) -> (billItems: [WKPickerItem], tipItems: [WKPickerItem])? {
        if let url = self.pickerItemsURL(currencySymbol),
            let data = NSData(contentsOfURL: url),
            let items = self.parsePickerItemsFromData(data) {
                self.applicationPreferences.currencySymbolsNeeded = false
                return items
        } else if let fallbackDataURL = NSBundle.mainBundle().URLForResource("fallbackPickerImages", withExtension: "data"),
            let fallbackData = NSData(contentsOfURL: fallbackDataURL),
            let items = self.parsePickerItemsFromData(fallbackData) {
                self.applicationPreferences.currencySymbolsNeeded = true
                return items
        } else {
            self.applicationPreferences.currencySymbolsNeeded = true
            return .None
        }
    }
    
    private func pickerItemsURL(currencySign: CurrencySign) -> NSURL? {
        let fileName = "\(self.currencyFormatter.currencyNameFromCurrencySign(currencySign))Images.data"
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
        return NSTimer.scheduledTimerWithTimeInterval(3.0, target: object, selector: "interfaceIdleTimerFired:", userInfo: nil, repeats: true)
    }
}
