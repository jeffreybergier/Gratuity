//
//  SettingsInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class SettingsInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var suggestedTipTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var tutorialLaunchTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var suggestedTipPercentageLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipSlider: WKInterfaceSlider?
    @IBOutlet private weak var tutorialLaunchSwitch: WKInterfaceSwitch?
    
    @IBOutlet private weak var currencySymbolLocalLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolDollarLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolPoundLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolEuroLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolYenLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolNoneLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipGroup: WKInterfaceGroup?
    @IBOutlet private weak var tutorialLaunchGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolLocalGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolDollarGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolPoundGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolEuroGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolYenGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolNoneGroup: WKInterfaceGroup?

    private var interfaceControllerIsConfigured = false
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let titleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let buttonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
        self.setTitle(NSLocalizedString("Close Settings", comment: ""))
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            // configure the titles
            self.suggestedTipTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Suggested Tip Percentage", comment: ""), attributes: self.titleTextAttributes))
            self.currencySymbolTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Currency Symbol", comment: ""), attributes: self.titleTextAttributes))
            self.tutorialLaunchTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Show Tutorial On Next Launch", comment: ""), attributes: self.titleTextAttributes))
            self.tutorialLaunchSwitch?.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Show", comment: ""), attributes: self.buttonTextAttributes))
            
            
            // configure the currency selection titles
            self.currencySymbolLocalLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Local", comment: ""), attributes: self.valueTextAttributes))
            self.currencySymbolDollarLabel?.setAttributedText(NSAttributedString(string: "$", attributes: self.valueTextAttributes))
            self.currencySymbolPoundLabel?.setAttributedText(NSAttributedString(string: "£", attributes: self.valueTextAttributes))
            self.currencySymbolEuroLabel?.setAttributedText(NSAttributedString(string: "€", attributes: self.valueTextAttributes))
            self.currencySymbolYenLabel?.setAttributedText(NSAttributedString(string: "¥", attributes: self.valueTextAttributes))
            self.currencySymbolNoneLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("None", comment: ""), attributes: self.valueTextAttributes))

            // configure the values that change
            self.suggestedTipSlider?.setValue(Float(round(self.dataSource.defaultsManager.suggestedTipPercentage * 100)))
            self.updateSuggestedTipPercentageUI()
            self.updateCurrencySymbolUI()
            self.updateTutorialLaunchUI()
            
            // this probably isn't needed, but no need to run this code a second time.
            self.interfaceControllerIsConfigured = true
        }
    }
    
    @IBAction private func suggestedTipSliderDidChange(value: Float) {
        let adjustedValue = value / 100
        self.dataSource.defaultsManager.suggestedTipPercentage = Double(adjustedValue)
        self.updateSuggestedTipPercentageUI()
    }
    
    @IBAction func tutorialLaunchSwitchDidChange(value: Bool) {
        self.dataSource.defaultsManager.showTutorialAtLaunch = value
    }
    
    @IBAction private func currencySymbolButtonLocalTapped() {
        self.dataSource.defaultsManager.overrideCurrencySymbol = CurrencySign.Default
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonDollarTapped() {
        self.dataSource.defaultsManager.overrideCurrencySymbol = CurrencySign.Dollar
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonPoundTapped() {
        self.dataSource.defaultsManager.overrideCurrencySymbol = CurrencySign.Pound
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonEuroTapped() {
        self.dataSource.defaultsManager.overrideCurrencySymbol = CurrencySign.Euro
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonYenTapped() {
        self.dataSource.defaultsManager.overrideCurrencySymbol = CurrencySign.Yen
        self.updateCurrencySymbolUI()
    }
    
    @IBAction private func currencySymbolButtonNoneTapped() {
        self.dataSource.defaultsManager.overrideCurrencySymbol = CurrencySign.None
        self.updateCurrencySymbolUI()
    }
    
    private func updateSuggestedTipPercentageUI() {
        let suggestedTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
        let suggestedTipPercentageString = self.dataSource.percentStringFromRawDouble(suggestedTipPercentage)
        self.suggestedTipPercentageLabel?.setAttributedText(NSAttributedString(string: suggestedTipPercentageString, attributes: self.valueTextAttributes))
    }
    
    private func updateTutorialLaunchUI() {
        self.tutorialLaunchSwitch?.setOn(self.dataSource.defaultsManager.showTutorialAtLaunch)
    }
    
    private func updateCurrencySymbolUI() {
        // set the colors all to the defaults
        self.currencySymbolLocalGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolDollarGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolPoundGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolEuroGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolYenGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        
        let currencySymbolOnDisk = self.dataSource.defaultsManager.overrideCurrencySymbol
        switch currencySymbolOnDisk {
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
        case .None:
            self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.ultraLightTextColor())
        }
    }
}
