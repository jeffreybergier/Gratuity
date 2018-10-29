//
//  PickerInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/23/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit

final class PickerInterfaceController: WKInterfaceController {
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get { return GratuitousWatchApplicationPreferences.sharedInstance.preferences }
        set {
            GratuitousWatchApplicationPreferences.sharedInstance.preferencesSetLocally = newValue
        }
    }
    fileprivate let currencyFormatter = GratuitousNumberFormatter(style: .respondsToLocaleChanges)
    
    @IBOutlet fileprivate var loadingGroup: WKInterfaceGroup?
    @IBOutlet fileprivate var mainGroup: WKInterfaceGroup?
    @IBOutlet fileprivate weak var animationImageView: WKInterfaceImage?
    @IBOutlet fileprivate var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet fileprivate var billAmountLabel: WKInterfaceLabel?
    @IBOutlet fileprivate var tipPicker: WKInterfacePicker?
    @IBOutlet fileprivate var billPicker: WKInterfacePicker?
    
    fileprivate var largeInterfaceUpdateNeeded = false
    fileprivate var smallInterfaceUpdateNeeded = false
    fileprivate var interfaceControllerConfiguredOnce = false
    
    fileprivate var interfaceIdleTimer: Timer?
    
    fileprivate enum InterfaceState {
        case loading, loaded
    }
    
    fileprivate var interfaceState: InterfaceState = .loading {
        didSet {
            switch self.interfaceState {
            case .loading:
                self.animationImageView?.startAnimatingWithImages(in: NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
                self.mainGroup?.setHidden(true)
                self.loadingGroup?.setHidden(false)
                self.setTitle("")
            case .loaded:
                self.animationImageView?.stopAnimating()
                self.mainGroup?.setHidden(false)
                self.loadingGroup?.setHidden(true)
                self.setTitle(LocalizedString.InterfaceTitle)
                self.billPicker?.focus()
            }
        }
    }
    
    fileprivate let largeValueTextAttributes = GratuitousUIColor.WatchFonts.hugeValueText
    fileprivate let smallValueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    
    fileprivate func resetInterfaceIdleTimer() {
        if let existingTimer = self.interfaceIdleTimer {
            existingTimer.invalidate()
            self.interfaceIdleTimer = nil
        }
        self.interfaceIdleTimer = Timer.interfaceIdleTimer(self)
    }
    
    // MARK: Initialize
    
    override func willActivate() {
        super.willActivate()
        self.updateUserActivity(HandoffTypes.MainTipInterface.rawValue, userInfo: ["string":"string"], webpageURL: .none)
        
        if self.interfaceControllerConfiguredOnce == false {
            self.interfaceControllerConfiguredOnce = true
            // configure notifications
            NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignDidChange(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: .none)
            NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignDidChange(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: .none)
            NotificationCenter.default.addObserver(self, selector: #selector(self.billTipValueChangeByRemote(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote), object: .none)
            
            // configure the menu
            self.addMenuItem(withImageNamed: "splitTipMenuIcon", title: PickerInterfaceController.LocalizedString.SplitTipMenuIconLabel, action: #selector(self.splitTipMenuButtonTapped))
            self.addMenuItem(withImageNamed: "settingsMenuIcon", title: PickerInterfaceController.LocalizedString.SettingsMenuIconLabel, action: #selector(self.settingsMenuButtonTapped))
            
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
    
    fileprivate func configurePickerItems() {
        // set the UI into a loading state
        self.interfaceState = .loading
        
        // tell the timer the interface is loaded
        // sometimes it takes longer to load than the timer allows
        // in those cases it loads twice
        self.largeInterfaceUpdateNeeded = false
        
        // dispatch the background for the long running items read from disk operation
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        backgroundQueue.async {
            if let items = self.accessiblePickerItems(self.applicationPreferences.overrideCurrencySymbol) {
                // dispatch back to the main queue to do the UI work
                DispatchQueue.main.async {
                    // this operation takes the longest
                    self.billPicker?.setItems(items.billItems)
                    self.tipPicker?.setItems(items.tipItems)
                    self.updateBillPicker()
                    self.updateTipPicker()
                    self.updateBigLabels()
                    self.interfaceState = .loaded
                }
            }
        }
    }
    
    var billPickerUpdatedProgrammatically = false
    fileprivate func updateBillPicker() {
        self.billPickerUpdatedProgrammatically = true
        let c = DefaultsCalculations(preferences: self.applicationPreferences)
        self.billPicker?.setSelectedItemIndex(c.billAmount - 1)
    }
    
    var tipPickerUpdatedProgrammatically = false
    fileprivate func updateTipPicker() {
        self.tipPickerUpdatedProgrammatically = true
        let c = DefaultsCalculations(preferences: self.applicationPreferences)
        self.tipPicker?.setSelectedItemIndex(c.tipAmount - 1)
    }
    
    fileprivate func updateBigLabels() {
        let c = DefaultsCalculations(preferences: self.applicationPreferences)
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
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Handle User Input

    @IBAction func billPickerChanged(_ value: Int) {
        if self.billPickerUpdatedProgrammatically == false {
            self.applicationPreferences.billIndexPathRow = value + 1
            self.applicationPreferences.tipIndexPathRow = 0
            self.updateBigLabels()
            self.updateTipPicker()
        }
        self.resetInterfaceIdleTimer()
        self.billPickerUpdatedProgrammatically = false
    }
    
    @IBAction func tipPickerChanged(_ value: Int) {
        if self.tipPickerUpdatedProgrammatically == false {
            self.applicationPreferences.tipIndexPathRow = value + 1
            self.updateBigLabels()
        }
        self.resetInterfaceIdleTimer()
        self.tipPickerUpdatedProgrammatically = false
    }
    
    @objc fileprivate func settingsMenuButtonTapped() {
        self.presentController(withName: "SettingsInterfaceController", context: .none)
    }
    
    @objc fileprivate func splitTipMenuButtonTapped() {
        if self.applicationPreferences.splitBillPurchased == true {
            self.presentController(withName: "SplitTotalInterfaceController", context: .none)
        } else {
            self.presentController(withName: "SplitBillPurchaseInterfaceController", context: .none)
        }
    }
    
    // MARK: Handle External UI Updates
    
    @objc fileprivate func currencySignDidChange(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.currencyFormatter.locale = Locale.current
            self.setLargeInterfaceRefreshNeeded()
        }
    }
    
    @objc fileprivate func billTipValueChangeByRemote(_ notification: Notification?) {
        DispatchQueue.main.async {
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
    
    @objc fileprivate func interfaceIdleTimerFired(_ timer: Timer?) {
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
    
    fileprivate func accessiblePickerItems(_ currencySymbol: CurrencySign) -> (billItems: [WKPickerItem], tipItems: [WKPickerItem])? {
        if let url = self.pickerItemsURL(currencySymbol),
            let data = try? Data(contentsOf: url),
            let items = self.parsePickerItemsFromData(data) {
                self.applicationPreferences.currencySymbolsNeeded = false
                return items
        } else if let fallbackDataURL = Bundle.main.url(forResource: "fallbackPickerImages", withExtension: "data"),
            let fallbackData = try? Data(contentsOf: fallbackDataURL),
            let items = self.parsePickerItemsFromData(fallbackData) {
                self.applicationPreferences.currencySymbolsNeeded = true
                return items
        } else {
            self.applicationPreferences.currencySymbolsNeeded = true
            return .none
        }
    }
    
    fileprivate func pickerItemsURL(_ currencySign: CurrencySign) -> URL? {
        let fileName = "\(self.currencyFormatter.currencyNameFromCurrencySign(currencySign))Images.data"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataURL = documentsURL.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: dataURL.path) == true { return dataURL } else { return .none }
    }
    
    fileprivate func parsePickerItemsFromData(_ data: Data?) -> (billItems: [WKPickerItem], tipItems: [WKPickerItem])? {
        var billItems = [WKPickerItem]()
        var tipItems = [WKPickerItem]()
        if let data = data,
            let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSArray {
                for (index, object) in array.enumerated() {
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
        
        if billItems.isEmpty == false { return returnValue } else { return .none }
    }
}

extension Timer {
    class func interfaceIdleTimer(_ object: AnyObject) -> Timer {
        return Timer.scheduledTimer(timeInterval: 3.0, target: object, selector: #selector(PickerInterfaceController.interfaceIdleTimerFired(_:)), userInfo: nil, repeats: true)
    }
}
