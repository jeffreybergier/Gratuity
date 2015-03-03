//
//  ExperimentalStepperBillInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/2/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class ExperimentalStepperBillInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var currencyLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var hundredsButton: WKInterfaceButton?
    @IBOutlet private weak var tensButton: WKInterfaceButton?
    @IBOutlet private weak var onesButton: WKInterfaceButton?
    
    @IBOutlet private weak var hundredsGroup: WKInterfaceGroup?
    @IBOutlet private weak var tensGroup: WKInterfaceGroup?
    @IBOutlet private weak var onesGroup: WKInterfaceGroup?
    
    @IBOutlet private weak var currencySlider: WKInterfaceSlider?
    @IBOutlet private weak var nextButton: WKInterfaceButton?
    
    private var currentContext = InterfaceControllerContext.NotSet
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    private var buttonValues: (hundreds: Int, tens: Int, ones: Int) = (0,0,0) {
        didSet {
            self.hundredsButton?.setTitle("\(self.buttonValues.hundreds)")
            self.tensButton?.setTitle("\(self.buttonValues.tens)")
            self.onesButton?.setTitle("\(self.buttonValues.ones)")
        }
    }
    private var selectedButton: SelectedButton = .None {
        didSet {
            let unselectedColor = UIColor.grayColor()
            let selectedColor = UIColor.whiteColor()
            switch self.selectedButton {
            case .None:
                self.hundredsGroup?.setBackgroundColor(unselectedColor)
                self.tensGroup?.setBackgroundColor(unselectedColor)
                self.onesGroup?.setBackgroundColor(unselectedColor)
            case .Hundreds:
                self.hundredsGroup?.setBackgroundColor(selectedColor)
                self.tensGroup?.setBackgroundColor(unselectedColor)
                self.onesGroup?.setBackgroundColor(unselectedColor)
                self.currencySlider?.setValue(Float(self.buttonValues.hundreds))
            case .Tens:
                self.hundredsGroup?.setBackgroundColor(unselectedColor)
                self.tensGroup?.setBackgroundColor(selectedColor)
                self.onesGroup?.setBackgroundColor(unselectedColor)
                self.currencySlider?.setValue(Float(self.buttonValues.tens))
            case .Ones:
                self.hundredsGroup?.setBackgroundColor(unselectedColor)
                self.tensGroup?.setBackgroundColor(unselectedColor)
                self.onesGroup?.setBackgroundColor(selectedColor)
                self.currencySlider?.setValue(Float(self.buttonValues.ones))
            }
        }
    }
    
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
        
        self.nextButton?.setTitle(NSLocalizedString("Next", comment: ""))
        self.selectedButton = .Tens
    }
    
    @IBAction private func sliderDidChange(value: Float) {
        switch self.selectedButton {
        case .None:
            break
        case .Hundreds:
            self.buttonValues.hundreds = Int(round(value))
        case .Tens:
            if self.buttonValues.tens == 9 {
                self.carryValue(valuePlace: .Tens)
            } else {
                self.buttonValues.tens = Int(round(value))
            }
        case .Ones:
            if self.buttonValues.ones == 9 {
                self.carryValue(valuePlace: .Ones)
            } else {
                self.buttonValues.ones = Int(round(value))
            }
        }
    }
    
    private func carryValue(#valuePlace: SelectedButton) {
        switch valuePlace {
        case .Tens:
            self.buttonValues.hundreds += 1
            self.buttonValues.tens = 0
            self.selectedButton = .Hundreds
        case .Ones:
            self.buttonValues.tens += 1
            self.buttonValues.ones = 0
            self.selectedButton = .Tens
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
    
    private enum SelectedButton {
        case None, Hundreds, Tens, Ones
    }
}