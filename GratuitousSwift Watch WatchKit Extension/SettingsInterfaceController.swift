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
    @IBOutlet private weak var maximumBillTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolTitleLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipSlider: WKInterfaceSlider?
    @IBOutlet private weak var maximumBillSlider: WKInterfaceSlider?
    
    @IBOutlet private weak var suggestedTipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private weak var maximumBillAmountLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var currencySymbolLocalLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolDollarLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolPoundLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolEuroLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolYenLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolNoneLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipGroup: WKInterfaceGroup?
    @IBOutlet private weak var maximumBillGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolLocalGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolDollarGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolPoundGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolEuroGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolYenGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolNoneGroup: WKInterfaceGroup?
    
    @IBOutlet private weak var animationGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?

    private var interfaceControllerIsConfigured = false
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let titleTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 14, fallbackStyle: UIFontStyle.Headline)]
    private let largerButtonTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.Headline)]
    
    override func willActivate() {
        super.willActivate()
        
        self.animationImageView?.setImageNamed("gratuityCap4-")
        self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
        
        self.setTitle(NSLocalizedString("Dismiss Settings", comment: ""))
        
        if self.interfaceControllerIsConfigured == false {
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            // set the color of all the labels
            self.suggestedTipTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.maximumBillTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.suggestedTipPercentageLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.maximumBillAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.currencySymbolTitleLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.currencySymbolLocalLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.currencySymbolDollarLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.currencySymbolPoundLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.currencySymbolEuroLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.currencySymbolYenLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.currencySymbolNoneLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            
            // configure the titles
            self.suggestedTipTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Suggested Tip Percentage", comment: ""), attributes: self.titleTextAttributes))
            self.maximumBillTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Maximum Bill Amount", comment: ""), attributes: self.titleTextAttributes))
            self.currencySymbolTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Currency Symbol", comment: ""), attributes: self.titleTextAttributes))
            
            // configure the currency selection titles
            self.currencySymbolLocalLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Local", comment: ""), attributes: self.largerButtonTextAttributes))
            self.currencySymbolDollarLabel?.setAttributedText(NSAttributedString(string: "$", attributes: self.largerButtonTextAttributes))
            self.currencySymbolPoundLabel?.setAttributedText(NSAttributedString(string: "£", attributes: self.largerButtonTextAttributes))
            self.currencySymbolEuroLabel?.setAttributedText(NSAttributedString(string: "€", attributes: self.largerButtonTextAttributes))
            self.currencySymbolYenLabel?.setAttributedText(NSAttributedString(string: "¥", attributes: self.largerButtonTextAttributes))
            self.currencySymbolNoneLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("None", comment: ""), attributes: self.largerButtonTextAttributes))
            
            // set the color of the groups that surround the buttons and sliders
            self.suggestedTipGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.maximumBillGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.updateCurrencySymbolUI()
            
            // configure the values that change
            self.suggestedTipSlider?.setValue(Float(round(self.dataSource.tipPercentage * 100)))
            self.maximumBillSlider?.setValue(Float(self.dataSource.numberOfRowsInBillTableForWatch))
            self.updateMaximumBillAmountUI()
            self.updateSuggestedTipPercentageUI()
            
            // this probably isn't needed, but no need to run this code a second time.
            self.interfaceControllerIsConfigured = true
            
            // unhide the UI
            self.suggestedTipTitleLabel?.setHidden(false)
            self.suggestedTipPercentageLabel?.setHidden(false)
            self.suggestedTipGroup?.setHidden(false)
            self.maximumBillTitleLabel?.setHidden(false)
            self.maximumBillAmountLabel?.setHidden(false)
            self.maximumBillGroup?.setHidden(false)
            self.currencySymbolTitleLabel?.setHidden(false)
            self.currencySymbolLocalGroup?.setHidden(false)
            self.currencySymbolDollarGroup?.setHidden(false)
            self.currencySymbolPoundGroup?.setHidden(false)
            self.currencySymbolEuroGroup?.setHidden(false)
            self.currencySymbolYenGroup?.setHidden(false)
            self.currencySymbolNoneGroup?.setHidden(false)
            self.animationGroup?.setHidden(true)
        }
    }
    
    @IBAction func suggestedTipSliderDidChange(value: Float) {
        let adjustedValue = value / 100
        self.dataSource.tipPercentage = Double(adjustedValue)
        self.updateSuggestedTipPercentageUI()
    }
    
    @IBAction func maximumBillSliderDidChange(value: Float) {
        let integerValue = Int(round(value))
        self.dataSource.numberOfRowsInBillTableForWatch = integerValue
        self.updateMaximumBillAmountUI()
    }
    
    @IBAction func currencySymbolButtonLocalTapped() {
        self.dataSource.overrideCurrencySymbol = CurrencySign.Default
        self.updateCurrencySymbolUI()
    }
    
    @IBAction func currencySymbolButtonDollarTapped() {
        self.dataSource.overrideCurrencySymbol = CurrencySign.Dollar
        self.updateCurrencySymbolUI()
    }
    
    @IBAction func currencySymbolButtonPoundTapped() {
        self.dataSource.overrideCurrencySymbol = CurrencySign.Pound
        self.updateCurrencySymbolUI()
    }
    
    @IBAction func currencySymbolButtonEuroTapped() {
        self.dataSource.overrideCurrencySymbol = CurrencySign.Euro
        self.updateCurrencySymbolUI()
    }
    
    @IBAction func currencySymbolButtonYenTapped() {
        self.dataSource.overrideCurrencySymbol = CurrencySign.Yen
        self.updateCurrencySymbolUI()
    }
    
    @IBAction func currencySymbolButtonNoneTapped() {
        self.dataSource.overrideCurrencySymbol = CurrencySign.None
        self.updateCurrencySymbolUI()
    }
    
    private func updateMaximumBillAmountUI() {
        let maximumBillAmount = self.dataSource.numberOfRowsInBillTableForWatch - 1
        let maximumBillAmountCurrencyString = self.dataSource.currencyStringFromInteger(maximumBillAmount)
        self.maximumBillAmountLabel?.setAttributedText(NSAttributedString(string: maximumBillAmountCurrencyString, attributes: self.largerButtonTextAttributes))
    }
    
    private func updateSuggestedTipPercentageUI() {
        let suggestedTipPercentage = self.dataSource.tipPercentage
        let suggestedTipPercentageString = self.dataSource.percentStringFromRawDouble(suggestedTipPercentage)
        self.suggestedTipPercentageLabel?.setAttributedText(NSAttributedString(string: suggestedTipPercentageString, attributes: self.largerButtonTextAttributes))
    }
    
    private func updateCurrencySymbolUI() {
        // set the colors all to the defaults
        self.currencySymbolLocalGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolDollarGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolPoundGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolEuroGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolYenGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        
        let currencySymbolOnDisk = self.dataSource.overrideCurrencySymbol
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
