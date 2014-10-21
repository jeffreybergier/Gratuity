//
//  TipViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class TipViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak private var tipPercentageTextLabel: UILabel!
    @IBOutlet weak private var totalAmountTextLabel: UILabel!
    @IBOutlet weak private var billAmountTableView: UITableView!
    @IBOutlet weak private var tipAmountTableView: UITableView!
    @IBOutlet weak private var tipPercentageTextLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var totalAmountTextLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var billAmountTableViewTitleTextLabel: UILabel!
    @IBOutlet weak private var billAmountTableViewTitleTextLabelView: UIView!
    @IBOutlet weak private var tipAmountTableViewTitleTextLabel: UILabel!
    @IBOutlet weak private var tipAmountTableViewTitleTextLabelView: UIView!
    
    private let MAXBILLAMOUNT = 500
    private let MAXTIPAMOUNT = 250
    private let BILLAMOUNTTAG = 0
    private let TIPAMOUNTTAG = 1
    private let IDEALTIPPERCENTAGE = 0.2
    
    private var textSizeAdjustment: NSNumber = NSNumber(double: 0.0)
    private var billAmountsArray: [NSNumber] = []
    private var tipAmountsArray: [NSNumber] = []
    private var totalAmountTextLabelAttributes = [NSString(): NSObject()]
    private var tipPercentageTextLabelAttributes = [NSString(): NSObject()]
    //private var userDidSelectBillAmountInTable = false
    private var billAmount: NSNumber = Double(0) {
        didSet {
            self.updateBillAmount(self.billAmount, TipAmount: nil, TipPercentage: nil)
        }
    }
    private var tipAmount: NSNumber = Double(0) {
        didSet {
            self.updateBillAmount(nil, TipAmount: self.tipAmount, TipPercentage: nil)
        }
    }
    private var tipPercentage: NSNumber = Double(0) {
        didSet {
            self.updateBillAmount(nil, TipAmount: nil, TipPercentage: self.tipPercentage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //prepare the arrays
        for i in 0..<self.MAXBILLAMOUNT {
            self.billAmountsArray.append(NSNumber(double: Double(i+1)))
        }
        for i in 0..<self.MAXTIPAMOUNT {
            self.tipAmountsArray.append(NSNumber(double: Double(i+1)))
        }
        
        //prepare the tableviews
        self.billAmountTableView.delegate = self
        self.billAmountTableView.dataSource = self
        self.billAmountTableView.tag = BILLAMOUNTTAG
        self.billAmountTableView.estimatedRowHeight = 76.0
        self.billAmountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        let tableViewCellClass:String! = NSStringFromClass(GratuitousTableViewCell).componentsSeparatedByString(".").last
        let billTableViewCellString = tableViewCellClass.stringByAppendingString("Bill")
        self.billAmountTableView.registerNib(UINib(nibName: tableViewCellClass, bundle: nil), forCellReuseIdentifier: billTableViewCellString)
        
        self.tipAmountTableView.delegate = self
        self.tipAmountTableView.dataSource = self
        self.tipAmountTableView.tag = TIPAMOUNTTAG
        self.tipAmountTableView.estimatedRowHeight = 76.0
        self.tipAmountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        let tipTableViewCellString = tableViewCellClass.stringByAppendingString("Tip")
        self.tipAmountTableView.registerNib(UINib(nibName: tableViewCellClass, bundle: nil), forCellReuseIdentifier: tipTableViewCellString)
        
        //configure color of view
        self.view.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.billAmountTableView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.tipAmountTableView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.tipPercentageTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        self.totalAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        self.tipAmountTableViewTitleTextLabel.textColor = GratuitousColorSelector.darkTextColor()
        self.billAmountTableViewTitleTextLabel.textColor = GratuitousColorSelector.darkTextColor()
        self.tipAmountTableViewTitleTextLabelView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
        self.billAmountTableViewTitleTextLabelView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
        
        //check screensize and set text side adjustment
        self.textSizeAdjustment = self.checkScreenHeightForTextSizeAdjuster()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareTotalAmountTextLabel()
        self.prepareTipPercentageTextLabel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.billAmount = Double(20.00)
    }
    
    private func prepareTotalAmountTextLabel() {
        let font = self.totalAmountTextLabel.font.fontWithSize(self.totalAmountTextLabel.font.pointSize * CGFloat(self.textSizeAdjustment.floatValue))
        let textColor = self.totalAmountTextLabel.textColor
        let text = self.totalAmountTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 2.0
        shadow.shadowOffset = CGSizeMake(2.0, 2.0)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.totalAmountTextLabelAttributes = attributes
        let attributedString = NSAttributedString(string: text!, attributes: self.totalAmountTextLabelAttributes)
        self.totalAmountTextLabel.attributedText = attributedString
    }
    
    private func prepareTipPercentageTextLabel() {
        let font = self.tipPercentageTextLabel.font.fontWithSize(self.tipPercentageTextLabel.font.pointSize * CGFloat(self.textSizeAdjustment.floatValue))
        let textColor = self.tipPercentageTextLabel.textColor
        let text = self.tipPercentageTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 2.0
        shadow.shadowOffset = CGSizeMake(2.0, 2.0)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.tipPercentageTextLabelAttributes = attributes
        let attributedString = NSAttributedString(string: text!, attributes: self.tipPercentageTextLabelAttributes)
        self.tipPercentageTextLabel.attributedText = attributedString
    }
    
    private func checkScreenHeightForTextSizeAdjuster() -> Double {
        var textSizeAdjustment = 1.0
        if UIScreen.mainScreen().bounds.size.height > UIScreen.mainScreen().bounds.size.width {
            if UIScreen.mainScreen().bounds.size.height > 735 {
                self.tipPercentageTextLabelTopConstraint.constant = -25.0
                self.totalAmountTextLabelBottomConstraint.constant = -5.0
                textSizeAdjustment = Double(1.1)
            } else if UIScreen.mainScreen().bounds.size.height > 666 {
                self.tipPercentageTextLabelTopConstraint.constant = -20.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                textSizeAdjustment = Double(1.0)
            } else if UIScreen.mainScreen().bounds.size.height > 567 {
                self.tipPercentageTextLabelTopConstraint.constant = -10.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                textSizeAdjustment = Double(0.85)
            } else if UIScreen.mainScreen().bounds.size.height > 479 {
                self.tipPercentageTextLabelTopConstraint.constant = -15.0
                self.totalAmountTextLabelBottomConstraint.constant = -12.0
                textSizeAdjustment = Double(0.76)
            }
        } else {
            if UIScreen.mainScreen().bounds.size.width > 735 {
                self.tipPercentageTextLabelTopConstraint.constant = -25.0
                self.totalAmountTextLabelBottomConstraint.constant = -5.0
                textSizeAdjustment = Double(1.1)
            } else if UIScreen.mainScreen().bounds.size.width > 666 {
                self.tipPercentageTextLabelTopConstraint.constant = -20.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                textSizeAdjustment = Double(1.0)
            } else if UIScreen.mainScreen().bounds.size.width > 567 {
                self.tipPercentageTextLabelTopConstraint.constant = -10.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                textSizeAdjustment = Double(0.85)
            } else if UIScreen.mainScreen().bounds.size.width > 479 {
                self.tipPercentageTextLabelTopConstraint.constant = -15.0
                self.totalAmountTextLabelBottomConstraint.constant = -12.0
                textSizeAdjustment = Double(0.76)
            }
        }
        return textSizeAdjustment
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case BILLAMOUNTTAG:
            return self.billAmountsArray.count
        default:
            return self.tipAmountsArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCellClass:String! = NSStringFromClass(GratuitousTableViewCell).componentsSeparatedByString(".").last
        switch tableView.tag {
        case BILLAMOUNTTAG:
            let billTableViewCellString = tableViewCellClass.stringByAppendingString("Bill")
            let cell = tableView.dequeueReusableCellWithIdentifier(billTableViewCellString) as GratuitousTableViewCell
            cell.billAmount = self.billAmountsArray[indexPath.row]
            return cell
        default:
            let tipTableViewCellString = tableViewCellClass.stringByAppendingString("Tip")
            let cell = tableView.dequeueReusableCellWithIdentifier(tipTableViewCellString) as GratuitousTableViewCell
            cell.billAmount = self.tipAmountsArray[indexPath.row]
            return cell
        }
    }
    
    private func updateBillAmount(billAmount:NSNumber?, TipAmount tipAmount:NSNumber?, TipPercentage tipPercentage:NSNumber?) {
        if let billAmount = billAmount {
            self.billAmountTableView.selectRowAtIndexPath(NSIndexPath(forRow: billAmount.integerValue - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            
            let tipAmount: NSNumber = billAmount.doubleValue * self.IDEALTIPPERCENTAGE
            let tipAmountRoundedString = NSString(format: "%.0f", tipAmount.doubleValue)
            let tipAmountRoundedNumber = NSNumber(double: tipAmountRoundedString.doubleValue)
            
            if tipAmountRoundedNumber.integerValue < 1 {
                self.tipAmount = Double(1.0)
            } else {
                self.tipAmount = tipAmountRoundedNumber
            }
        }
        if let tipAmount = tipAmount {
            self.tipAmountTableView.selectRowAtIndexPath(NSIndexPath(forRow: tipAmount.integerValue - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            
            self.tipPercentage = tipAmount.doubleValue/self.billAmount.doubleValue
        }
        if let tipPercentage = tipPercentage {
            self.tipPercentageTextLabel.attributedText = NSAttributedString(string: NSString(format: "%.0f%%", tipPercentage.doubleValue*100), attributes: self.tipPercentageTextLabelAttributes)
            self.totalAmountTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.tipAmount.doubleValue+self.billAmount.doubleValue), attributes: self.totalAmountTextLabelAttributes)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch tableView.tag {
        case BILLAMOUNTTAG:
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            let billAmountSelected = self.billAmountsArray[indexPath.row]
            self.billAmount = self.billAmountsArray[indexPath.row]
        default:
            let tipAmountSelected = self.tipAmountsArray[indexPath.row]
            self.tipAmount = self.tipAmountsArray[indexPath.row]
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let tableView = scrollView as UITableView
        switch tableView.tag {
        case BILLAMOUNTTAG:
            var point3 = tableView.frame.origin
            point3.x += tableView.frame.size.width / 2
            point3.y += tableView.frame.size.height / 2
            point3 = tableView.convertPoint(point3, fromView: tableView.superview)
            let indexPath = tableView.indexPathForRowAtPoint(point3)
            println("BillAmount IndexPathSection:\(indexPath?.section) AndIndexPathRow: \(indexPath?.row)")
            tableView.selectRowAtIndexPath(indexPath?, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        default:
            let indexPath = tableView.indexPathForRowAtPoint(CGPointMake(tableView.frame.size.width/2, tableView.frame.size.height/2))
            //println("TipAmount IndexPath: \(indexPath?.row)")
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as UITableView
        switch tableView.tag {
        case BILLAMOUNTTAG:
            var point3 = tableView.frame.origin
            point3.x += tableView.frame.size.width / 2
            point3.y += tableView.frame.size.height / 2
            point3 = tableView.convertPoint(point3, fromView: tableView.superview)
            let indexPath = tableView.indexPathForRowAtPoint(point3)
            
            println("BillAmount IndexPathRow: \(indexPath?.row)")
            //tableView.selectRowAtIndexPath(indexPath?, animated: false, scrollPosition: UITableViewScrollPosition.None)
//            if let indexPath = indexPath {
//                let billAmountSelected = self.billAmountsArray[indexPath.row]
//                self.billAmount = self.billAmountsArray[indexPath.row]
//            }
        default:
            let indexPath = tableView.indexPathForRowAtPoint(CGPointMake(tableView.frame.size.width/2, tableView.frame.size.height/2))
            //println("TipAmount IndexPath: \(indexPath?.row)")       
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76.0
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

