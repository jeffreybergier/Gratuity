//
//  SettingsInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

final class SettingsInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var suggestedTipTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var suggestedTipPercentageLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipSlider: WKInterfaceSlider?
    
    @IBOutlet private weak var currencySymbolLocalLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolDollarLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolPoundLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolEuroLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolYenLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolNoneLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolLocalGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolDollarGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolPoundGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolEuroGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolYenGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolNoneGroup: WKInterfaceGroup?

    private var interfaceControllerIsConfigured = false
    
    private let titleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let largeValueTextAttributes = GratuitousUIColor.WatchFonts.splitBillValueText
    
    private var applicationPreferences: GratuitousUserDefaults {
        get { return GratuitousWatchApplicationPreferences.sharedInstance.preferences }
        set { GratuitousWatchApplicationPreferences.sharedInstance.preferencesSetLocally = newValue }
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.updateUserActivity(HandoffTypes.SettingsInterface.rawValue, userInfo: ["string": "string"], webpageURL: .None)
        
        if self.interfaceControllerIsConfigured == false {
        self.setTitle(SettingsInterfaceController.LocalizedString.CloseSettingsTitle)
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: .None)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "percentageMyHaveChanged:", name: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote, object: .None)
            
            // configure the titles
            self.suggestedTipTitleLabel?.setAttributedText(NSAttributedString(string: SettingsInterfaceController.LocalizedString.SuggestedTipPercentageHeader, attributes: self.titleTextAttributes))
            self.currencySymbolTitleLabel?.setAttributedText(NSAttributedString(string: SettingsInterfaceController.LocalizedString.CurrencySymbolHeader, attributes: self.titleTextAttributes))
            
            // configure the currency selection titles
            self.currencySymbolLocalLabel?.setAttributedText(NSAttributedString(string: SettingsInterfaceController.LocalizedString.LocalCurrencyRowLabel, attributes: self.valueTextAttributes))
            self.currencySymbolDollarLabel?.setAttributedText(NSAttributedString(string: "$", attributes: self.valueTextAttributes))
            self.currencySymbolPoundLabel?.setAttributedText(NSAttributedString(string: "£", attributes: self.valueTextAttributes))
            self.currencySymbolEuroLabel?.setAttributedText(NSAttributedString(string: "€", attributes: self.valueTextAttributes))
            self.currencySymbolYenLabel?.setAttributedText(NSAttributedString(string: "¥", attributes: self.valueTextAttributes))
            self.currencySymbolNoneLabel?.setAttributedText(NSAttributedString(string: SettingsInterfaceController.LocalizedString.NoneCurrencyRowLabel, attributes: self.valueTextAttributes))

            // configure the values that change
            self.suggestedTipSlider?.setValue(Float(round(self.applicationPreferences.suggestedTipPercentage * 100)))
            self.updateSuggestedTipPercentageUI()
            self.updateCurrencySymbolUI()
            
            // this probably isn't needed, but no need to run this code a second time.
            self.interfaceControllerIsConfigured = true
        }
    }
    
    @objc private func currencySignChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateCurrencySymbolUI()
        }
    }
    
    @objc private func percentageMyHaveChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateSuggestedTipPercentageUI()
        }
    }
    
    @IBAction private func suggestedTipSliderDidChange(value: Float) {
        let adjustedValue = value /? 100
        self.applicationPreferences.suggestedTipPercentage = Double(adjustedValue)
        self.updateSuggestedTipPercentageUI()
    }
    
    @IBAction private func currencySymbolButtonLocalTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.Default
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonDollarTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.Dollar
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonPoundTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.Pound
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonEuroTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.Euro
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonYenTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.Yen
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonNoneTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.NoSign
        self.updateCurrencySymbolUI()
    }
    
    private func updateSuggestedTipPercentageUI() {
        let suggestedTipPercentage = Int(round(self.applicationPreferences.suggestedTipPercentage * 100))
        let suggestedTipPercentageString = "\(suggestedTipPercentage)%"
        self.suggestedTipPercentageLabel?.setAttributedText(NSAttributedString(string: suggestedTipPercentageString, attributes: self.largeValueTextAttributes))
    }
    
    private func updateCurrencySymbolUI() {
        // set the colors all to the defaults
        self.currencySymbolLocalGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolDollarGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolPoundGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolEuroGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolYenGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        
        let currencySign = self.applicationPreferences.overrideCurrencySymbol
        switch currencySign {
        case .Default:
            self.currencySymbolLocalGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .Dollar:
            self.currencySymbolDollarGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .Pound:
            self.currencySymbolPoundGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .Euro:
            self.currencySymbolEuroGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .Yen:
            self.currencySymbolYenGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .NoSign:
            self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        }
    }
    
    override func willDisappear() {
        super.willDisappear()
        
        self.invalidateUserActivity()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
