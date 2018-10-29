//
//  SettingsInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

final class SettingsInterfaceController: WKInterfaceController {
    
    @IBOutlet fileprivate weak var suggestedTipTitleLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var currencySymbolTitleLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var suggestedTipPercentageLabel: WKInterfaceLabel?
    
    @IBOutlet fileprivate weak var suggestedTipSlider: WKInterfaceSlider?
    
    @IBOutlet fileprivate weak var currencySymbolLocalLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var currencySymbolDollarLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var currencySymbolPoundLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var currencySymbolEuroLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var currencySymbolYenLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var currencySymbolNoneLabel: WKInterfaceLabel?
    
    @IBOutlet fileprivate weak var suggestedTipGroup: WKInterfaceGroup?
    @IBOutlet fileprivate weak var currencySymbolLocalGroup: WKInterfaceGroup?
    @IBOutlet fileprivate weak var currencySymbolDollarGroup: WKInterfaceGroup?
    @IBOutlet fileprivate weak var currencySymbolPoundGroup: WKInterfaceGroup?
    @IBOutlet fileprivate weak var currencySymbolEuroGroup: WKInterfaceGroup?
    @IBOutlet fileprivate weak var currencySymbolYenGroup: WKInterfaceGroup?
    @IBOutlet fileprivate weak var currencySymbolNoneGroup: WKInterfaceGroup?

    fileprivate var interfaceControllerIsConfigured = false
    
    fileprivate let titleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    fileprivate let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    fileprivate let largeValueTextAttributes = GratuitousUIColor.WatchFonts.splitBillValueText
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get { return GratuitousWatchApplicationPreferences.sharedInstance.preferences }
        set { GratuitousWatchApplicationPreferences.sharedInstance.preferencesSetLocally = newValue }
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.updateUserActivity(HandoffTypes.SettingsInterface.rawValue, userInfo: ["string": "string"], webpageURL: .none)
        
        if self.interfaceControllerIsConfigured == false {
        self.setTitle(SettingsInterfaceController.LocalizedString.CloseSettingsTitle)
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = DispatchQueue.global(qos: .userInteractive)
            backgroundQueue.async {
                self.configureInterfaceController()
            }
        }
    }
    
    fileprivate func configureInterfaceController() {
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: .none)
            NotificationCenter.default.addObserver(self, selector: #selector(self.percentageMyHaveChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote), object: .none)
            
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
    
    @objc fileprivate func currencySignChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.updateCurrencySymbolUI()
        }
    }
    
    @objc fileprivate func percentageMyHaveChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.updateSuggestedTipPercentageUI()
        }
    }
    
    @IBAction fileprivate func suggestedTipSliderDidChange(_ value: Float) {
        let adjustedValue = value /? 100
        self.applicationPreferences.suggestedTipPercentage = Double(adjustedValue)
        self.updateSuggestedTipPercentageUI()
    }
    
    @IBAction fileprivate func currencySymbolButtonLocalTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.default
        self.updateCurrencySymbolUI()
    }
    
    @IBAction fileprivate func currencySymbolButtonDollarTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.dollar
        self.updateCurrencySymbolUI()
    }
    
    @IBAction fileprivate func currencySymbolButtonPoundTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.pound
        self.updateCurrencySymbolUI()
    }
    
    @IBAction fileprivate func currencySymbolButtonEuroTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.euro
        self.updateCurrencySymbolUI()
    }
    
    @IBAction fileprivate func currencySymbolButtonYenTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.yen
        self.updateCurrencySymbolUI()
    }
    
    @IBAction fileprivate func currencySymbolButtonNoneTapped() {
        self.applicationPreferences.overrideCurrencySymbol = CurrencySign.noSign
        self.updateCurrencySymbolUI()
    }
    
    fileprivate func updateSuggestedTipPercentageUI() {
        let suggestedTipPercentage = Int(round(self.applicationPreferences.suggestedTipPercentage * 100))
        let suggestedTipPercentageString = "\(suggestedTipPercentage)%"
        self.suggestedTipPercentageLabel?.setAttributedText(NSAttributedString(string: suggestedTipPercentageString, attributes: self.largeValueTextAttributes))
    }
    
    fileprivate func updateCurrencySymbolUI() {
        // set the colors all to the defaults
        self.currencySymbolLocalGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolDollarGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolPoundGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolEuroGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolYenGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        
        let currencySign = self.applicationPreferences.overrideCurrencySymbol
        switch currencySign {
        case .default:
            self.currencySymbolLocalGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .dollar:
            self.currencySymbolDollarGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .pound:
            self.currencySymbolPoundGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .euro:
            self.currencySymbolEuroGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .yen:
            self.currencySymbolYenGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        case .noSign:
            self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        }
    }
    
    override func willDisappear() {
        super.willDisappear()
        
        self.invalidateUserActivity()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
