//
//  ThreeButtonStepperInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/2/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class ThreeButtonStepperInterfaceController: GratuitousMenuInterfaceController {
    
    @IBOutlet private weak var currencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var instructionalTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var hundredsButtonTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var tensButtonTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var onesButtonTextLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var hundredsButton: WKInterfaceButton?
    @IBOutlet private weak var tensButton: WKInterfaceButton?
    @IBOutlet private weak var onesButton: WKInterfaceButton?
    
    @IBOutlet private weak var hundredsGroup: WKInterfaceGroup?
    @IBOutlet private weak var tensGroup: WKInterfaceGroup?
    @IBOutlet private weak var onesGroup: WKInterfaceGroup?
    
    @IBOutlet private weak var currencyValuesGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySlider: WKInterfaceSlider?
    @IBOutlet private weak var currencySliderGroup: WKInterfaceGroup?
    @IBOutlet private weak var nextButton: WKInterfaceButton?
    @IBOutlet private weak var nextButtonTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var nextButtonGroup: WKInterfaceGroup?
    @IBOutlet private weak var backgroundImageGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    
    private(set) var currentContext = ThreeButtonStepperInterfaceContext.NotSet
    private var interfaceControllerIsConfigured = false
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let subtitleTextAttributes = GratuitousUIColor.WatchFonts.subtitleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let nextButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    private var buttonValues: (hundreds: Int, tens: Int, ones: Int) = (0,0,0) {
        didSet {
            self.hundredsButtonTextLabel?.setAttributedText(NSAttributedString(string: "\(self.buttonValues.hundreds)", attributes: self.valueTextAttributes))
            self.tensButtonTextLabel?.setAttributedText(NSAttributedString(string: "\(self.buttonValues.tens)", attributes: self.valueTextAttributes))
            self.onesButtonTextLabel?.setAttributedText(NSAttributedString(string: "\(self.buttonValues.ones)", attributes: self.valueTextAttributes))
        }
    }
    
    private var selectedButton: SelectedButton = .None {
        didSet {
            self.currencySlider?.setValue(-1) // this fixes a bug where the slider was not setting itself to 0 on ocassion
            switch self.selectedButton {
            case .None:
                self.hundredsGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.tensGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.onesGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            case .Hundreds:
                self.hundredsGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
                self.tensGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.onesGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.currencySlider?.setValue(Float(self.buttonValues.hundreds))
            case .Tens:
                self.hundredsGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.tensGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
                self.onesGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.currencySlider?.setValue(Float(self.buttonValues.tens))
            case .Ones:
                self.hundredsGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.tensGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
                self.onesGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
                self.currencySlider?.setValue(Float(self.buttonValues.ones))
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let currentContext: ThreeButtonStepperInterfaceContext
        if let contextString = context as? String {
            currentContext = ThreeButtonStepperInterfaceContext(rawValue: contextString) !! ThreeButtonStepperInterfaceContext.Bill
        } else {
            fatalError("StepperInterfaceController: Context not present during awakeWithContext:")
        }
        self.currentContext = currentContext
    }
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            
            self.animationImageView?.setImageNamed("gratuityCap4-")
            self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
            
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            var currencySymbolString = "$"
            if let currencySymbolCharacter = Array(self.dataSource.currencyStringFromInteger(0)).first {
                let stringFromCharacter = String(currencySymbolCharacter)
                if stringFromCharacter == "0" { // if the preference is set to none, a 0 was showing in the UI instead of blank
                    currencySymbolString = ""
                } else {
                    currencySymbolString = stringFromCharacter
                }
            }
            self.currencyLabel?.setAttributedText(NSAttributedString(string: currencySymbolString, attributes: self.valueTextAttributes))
            self.currencyLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            
            self.nextButtonTextLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.nextButtonTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Next", comment: ""), attributes: self.nextButtonTextAttributes))
            
            self.instructionalTextLabel?.setText("")
            self.instructionalTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            
            self.tipPercentageLabel?.setText("-%")
            self.tipPercentageLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            
            self.hundredsButtonTextLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.tensButtonTextLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.onesButtonTextLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            
            self.nextButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.currencySliderGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            
            switch self.currentContext {
            case .Bill:
                self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Bill Amount", comment: ""), attributes: self.subtitleTextAttributes))
                self.instructionalTextLabel?.setHidden(true)
                self.setTitle(NSLocalizedString("Bill Amount", comment: ""))
                self.tipPercentageLabel?.setHidden(true)
                
                self.updateUIWithCurrencyAmount(self.dataSource.defaultsManager.billIndexPathRow)
            case .Tip:
                self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Tip Amount", comment: ""), attributes: self.subtitleTextAttributes))
                self.instructionalTextLabel?.setHidden(true)
                self.setTitle(NSLocalizedString("Tip Amount", comment: ""))
                
                let billAmountOnDisk = self.dataSource.defaultsManager.billIndexPathRow
                let tipAmountOnDisk = self.dataSource.defaultsManager.tipIndexPathRow
                let suggestedTipOnDisk = self.dataSource.defaultsManager.suggestedTipPercentage
                let calculatedTip = tipAmountOnDisk > 0 ? tipAmountOnDisk : Int(round(Double(billAmountOnDisk) * suggestedTipOnDisk))
                let tipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(calculatedTip), bottom: Double(billAmountOnDisk)) ?? 0.0
                
                self.updateUIWithCurrencyAmount(calculatedTip)
                self.tipPercentageLabel?.setAttributedText(NSAttributedString(string: self.dataSource.percentStringFromRawDouble(tipPercentage), attributes: self.nextButtonTextAttributes))
                self.tipPercentageLabel?.setHidden(false)
            default:
                fatalError("StepperInterfaceController: Context was invalid while switching.")
            }
            self.selectedButton = .Ones
            
            self.backgroundImageGroup?.setHidden(true)
            self.currencyValuesGroup?.setHidden(false)
            self.nextButtonGroup?.setHidden(false)
            self.currencySliderGroup?.setHidden(false)
            self.interfaceControllerIsConfigured = true
        }
    }
    
    private func updateUIWithCurrencyAmount(currencyAmount: Int?) {
        if let currencyAmount = currencyAmount {
            if currencyAmount > 999 {
                self.buttonValues = (9,9,9) // this display cannot show more than 999, so if its, we will use that as the new billAmount
            } else {
                let intString = "\(currencyAmount)"
                let intArray = Array(intString).map { String($0).toInt() }
                for (index, integer) in enumerate(intArray.reverse()) {
                    switch index {
                    case 0:
                        self.buttonValues.ones = integer !! 0
                    case 1:
                        self.buttonValues.tens = integer !! 0
                    case 2:
                        self.buttonValues.hundreds = integer !! 0
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func calculateValueFromUI() -> Int {
        let UIArray = [self.buttonValues.hundreds, self.buttonValues.tens, self.buttonValues.ones]
        var compiledInt = 0
        for (index, integer) in enumerate(UIArray.reverse()) {
            // for index 0 the integer needs to be multiplied by 1.
            // For index 1, it needs to be multiplied by 10
            // for index 2, it needs to be multipled by 100
            // the index == the number of zeros needed after the 1.
            // this for loop accomplishes that.
            var multiplier = 1
            for i in 0..<index {
                multiplier *= 10
            }
            compiledInt += integer * multiplier
        }
        return compiledInt
    }
    
    private func writeValueToDisk(value: Int) {
        switch self.currentContext {
        case .Bill:
            self.dataSource.defaultsManager.billIndexPathRow = value
        case .Tip:
            self.dataSource.defaultsManager.tipIndexPathRow = value
        default:
            break
        }
    }
    
    @IBAction private func didTapNextButton() {
        self.writeValueToDisk(self.calculateValueFromUI())
        switch self.currentContext {
        case .Bill:
            self.pushControllerWithName("ThreeButtonStepperTipInterfaceController", context: ThreeButtonStepperInterfaceContext.Tip.rawValue)
        case .Tip:
            self.pushControllerWithName("TotalAmountInterfaceController", context: nil)
        default:
            break
        }
    }
    
    @IBAction private func sliderDidChange(value: Float) {
        switch self.selectedButton {
        case .None:
            break
        case .Hundreds:
            if self.buttonValues.hundreds == Int(round(value)) && self.buttonValues.hundreds == 0 {
                self.carryValueDown(valuePlace: .Hundreds)
            } else {
                self.buttonValues.hundreds = Int(round(value))
            }
        case .Tens:
            if self.buttonValues.tens == Int(round(value)) {
                switch self.buttonValues.tens {
                case 9:
                    self.carryValueUp(valuePlace: .Tens)
                case 0:
                    self.carryValueDown(valuePlace: .Tens)
                default:
                    break
                }
            } else {
                self.buttonValues.tens = Int(round(value))
            }
        case .Ones:
            if self.buttonValues.ones == Int(round(value)) && self.buttonValues.ones == 9 {
                self.carryValueUp(valuePlace: .Ones)
            } else {
                self.buttonValues.ones = Int(round(value))
            }
        }
        if let tipPercentageLabel = self.tipPercentageLabel {
            // if this outlet is set, we are tip controller and we need to update the tip percentage label
            let billAmount = self.dataSource.defaultsManager.billIndexPathRow
            let tipAmount = self.calculateValueFromUI()
            let calculatedTipPercentage = Double(tipAmount) / Double(billAmount)
            tipPercentageLabel.setAttributedText(NSAttributedString(string: self.dataSource.percentStringFromRawDouble(calculatedTipPercentage), attributes: self.nextButtonTextAttributes))
        }
        self.writeValueToDisk(self.calculateValueFromUI())
    }
    
    private func carryValueUp(#valuePlace: SelectedButton) {
        switch valuePlace {
        case .Tens:
            self.buttonValues.hundreds += 1
            self.buttonValues.tens = 0
            self.selectedButton = .Tens
        case .Ones:
            self.buttonValues.tens += 1
            self.buttonValues.ones = 0
            self.selectedButton = .Ones
        default:
            break
        }
    }
    
    private func carryValueDown(#valuePlace: SelectedButton) {
        // this may or may not make sense
        // it can lead to some strange behavior and some data loss
        // may remove this function before release
        switch valuePlace {
        case .Tens:
            self.buttonValues.tens = 0
            //self.buttonValues.ones = 9
            //self.selectedButton = .Ones
        case .Hundreds:
            self.buttonValues.hundreds = 0
            //            self.buttonValues.tens = 9
            //            self.buttonValues.ones = 9
            //            self.selectedButton = .Tens
        default:
            break
        }
    }
    
    @IBAction private func hundredButtonSelected() {
        self.selectedButton = .Hundreds
    }
    
    @IBAction private func tensButtonSelected() {
        self.selectedButton = .Tens
    }
    
    @IBAction private func onesButtonSelected() {
        self.selectedButton = .Ones
    }
    
    private enum SelectedButton: Printable {
        case None, Hundreds, Tens, Ones
        var description: String {
            switch self {
            case .None:
                return "SelectedButton.None"
            case .Hundreds:
                return "SelectedButton.Hundreds"
            case .Tens:
                return "SelectedButton.Tens"
            case .Ones:
                return "SelectedButton.Ones"
            }
        }
    }
}