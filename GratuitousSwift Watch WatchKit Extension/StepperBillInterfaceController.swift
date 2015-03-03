//
//  StepperBillInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class StepperInterfaceController: WKInterfaceController {

    @IBOutlet private weak var instructionTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencyAmountTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySlider: WKInterfaceSlider?
    @IBOutlet private weak var nextButton: WKInterfaceButton?
    @IBOutlet private weak var tipPercentageLabel: WKInterfaceLabel?
    
    private var currentContext = InterfaceControllerContext.NotSet
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    private var billAmountMultiplier = 1 //set to 10 when choosing the bill in 2 screens
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var currentContext: InterfaceControllerContext
        //let currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.StepperPagedTens
        } else {
            fatalError("StepperInterfaceController: Context not present during awakeWithContext:")
        }
        self.currentContext = currentContext
    }

    override func willActivate() {
        super.willActivate()
        
        self.instructionTextLabel?.setText("")
        self.currencyAmountTextLabel?.setText("$ –")
        self.tipPercentageLabel?.setText("– %")
        self.nextButton?.setTitle(NSLocalizedString("Next", comment: ""))
        self.tipPercentageLabel?.setHidden(true)
        
        switch self.currentContext {
        case .StepperInfinite:
            self.instructionTextLabel?.setText(NSLocalizedString("Choose the amount on the Bill", comment: ""))
            self.configureBillAmountFromDisk(round: false)
        case .StepperPagedTens:
            self.billAmountMultiplier = 10
            self.instructionTextLabel?.setText(NSLocalizedString("Choose the amount closest to the Bill", comment: ""))
            self.configureBillAmountFromDisk(round: true)
        case .StepperPagedOnes:
            self.instructionTextLabel?.setText(NSLocalizedString("Adjust the amount to match the Bill", comment: ""))
        case .StepperTipChooser:
            self.instructionTextLabel?.setText(NSLocalizedString("Choose a Tip amount", comment: ""))
            self.tipPercentageLabel?.setHidden(false)
        default:
            fatalError("StepperInterfaceController: Context was invalid while switching.")
        }
    }
    
    private func configureBillAmountFromDisk(#round: Bool) {
        let billAmount = round ? Int(roundf(Float(self.dataSource.billAmount !! 0 / self.billAmountMultiplier))) * self.billAmountMultiplier : self.dataSource.billAmount !! 0
        println("WillActivate: Round = \(round), BillAmount = \(billAmount)")
        self.currencyAmountTextLabel?.setText(self.dataSource.currencyStringFromInteger(billAmount))
        if billAmount > 0 {
            self.currencySlider?.setValue(Float(billAmount))
        }
    }
    
    @IBAction @objc private func didChangeSlider(value: Float) {
        let adjustedValue = self.billAmountMultiplier * Int(value)
        println("DidChangeSlider: AdjustedValue = \(adjustedValue)")
        self.dataSource.billAmount = adjustedValue
        self.currencyAmountTextLabel?.setText(self.dataSource.currencyStringFromInteger(adjustedValue))
    }
    
    @IBAction func didTapNextButton() {
        switch self.currentContext {
        case .StepperInfinite:
            break
        case .StepperPagedTens:
            break
        case .StepperPagedOnes:
            break
        case .StepperTipChooser:
            break
        default:
            fatalError("StepperInterfaceController: Context was invalid while switching.")
        }
    }
}
