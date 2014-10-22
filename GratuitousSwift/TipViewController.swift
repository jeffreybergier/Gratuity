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
    //@IBOutlet weak private var billAmountTableViewTitleTextLabelView: UIView!
    @IBOutlet weak private var tipAmountTableViewTitleTextLabel: UILabel!
    @IBOutlet weak private var tipAmountTableViewTitleTextLabelView: UIView!
    @IBOutlet weak var billAmountSelectedSurroundView: UIView!
    @IBOutlet weak var billAmountLowerGradientView: GratuitousGradientView!
    
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
    private var userIsDraggingBillAmountTableView: Bool = false
    
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
        //self.billAmountTableViewTitleTextLabelView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
        
        //prepare the cell select surrounds
        self.billAmountSelectedSurroundView.backgroundColor = UIColor.clearColor()
        self.billAmountSelectedSurroundView.layer.borderWidth = 3.0
        self.billAmountSelectedSurroundView.layer.cornerRadius = 0.0
        self.billAmountSelectedSurroundView.layer.borderColor = GratuitousColorSelector.lightBackgroundColor().CGColor
        
        //prepare lower gradient view so its upside down
        self.billAmountLowerGradientView.isUpsideDown = true
        
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
        
        self.billAmountTableView.selectRowAtIndexPath(NSIndexPath(forRow: 19, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
    }
    
    private func indexPathInCenterOfTable(tableView: UITableView) -> NSIndexPath {
        var indexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        var point = tableView.frame.origin
        point.x += tableView.frame.size.width / 2
        point.y += tableView.frame.size.height / 2
        point = tableView.convertPoint(point, fromView: tableView.superview)
        if let optionalIndexPath = tableView.indexPathForRowAtPoint(point) {
            indexPath = optionalIndexPath
        }
        
        return indexPath
    }
    
    private func updateBillAmountText() {
        let billAmountIndexPath = self.indexPathInCenterOfTable(self.billAmountTableView)
        let billCell = self.billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as GratuitousTableViewCell
        let billAmount = billCell.billAmount
        
        let tipAmount: NSNumber = billAmount.doubleValue * self.IDEALTIPPERCENTAGE
        let tipAmountRoundedString = NSString(format: "%.0f", tipAmount.doubleValue)
        var tipAmountRoundedNumber = NSNumber(double: tipAmountRoundedString.doubleValue)
        
        if tipAmountRoundedNumber.integerValue < 1 {
            tipAmountRoundedNumber = Double(1.0)
        }
        
        let tipIndexPath = NSIndexPath(forRow: tipAmountRoundedNumber.integerValue-1, inSection: 0)
        self.tipAmountTableView.selectRowAtIndexPath(tipIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        
        let totalAmount = billAmount.doubleValue + tipAmountRoundedNumber.doubleValue
        let totalAmountAttributedString = NSAttributedString(string: NSString(format: "$%.0f", totalAmount), attributes: self.totalAmountTextLabelAttributes)
        let tipPercentageAttributedString = NSAttributedString(string: NSString(format: "%.0f%%", (tipAmountRoundedNumber.doubleValue/billAmount.doubleValue)*100), attributes: self.tipPercentageTextLabelAttributes)
        self.totalAmountTextLabel.attributedText = totalAmountAttributedString
        self.tipPercentageTextLabel.attributedText = tipPercentageAttributedString
    }
    
    private func updateTipAmountText() {
        let billAmountIndexPath = self.indexPathInCenterOfTable(self.billAmountTableView)
        let billCell = self.billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as GratuitousTableViewCell
        let billAmount = billCell.billAmount
        
        let tipAmountIndexPath = self.indexPathInCenterOfTable(self.tipAmountTableView)
        let tipCell = self.tipAmountTableView.cellForRowAtIndexPath(tipAmountIndexPath) as GratuitousTableViewCell
        let tipAmount = tipCell.billAmount
        
        let tipAmountRoundedString = NSString(format: "%.0f", tipAmount.doubleValue)
        var tipAmountRoundedNumber = NSNumber(double: tipAmountRoundedString.doubleValue)
        
        if tipAmountRoundedNumber.integerValue < 1 {
            tipAmountRoundedNumber = Double(1.0)
        }
        
        let totalAmount = billAmount.doubleValue + tipAmountRoundedNumber.doubleValue
        let totalAmountAttributedString = NSAttributedString(string: NSString(format: "$%.0f", totalAmount), attributes: self.totalAmountTextLabelAttributes)
        let tipPercentageAttributedString = NSAttributedString(string: NSString(format: "%.0f%%", (tipAmountRoundedNumber.doubleValue/billAmount.doubleValue)*100), attributes: self.tipPercentageTextLabelAttributes)
        self.totalAmountTextLabel.attributedText = totalAmountAttributedString
        self.tipPercentageTextLabel.attributedText = tipPercentageAttributedString
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch tableView.tag {
        case BILLAMOUNTTAG:
//            var animated = false
//            let middleIndexPath = self.indexPathInCenterOfTable(tableView)
//            if indexPath.row > middleIndexPath.row {
//                if (indexPath.row - middleIndexPath.row) > 0 {
//                    self.userIsDraggingBillAmountTableView = true
//                    animated = true
//                }
//            } else {
//                if (middleIndexPath.row - indexPath.row) > 0 {
//                    self.userIsDraggingBillAmountTableView = true
//                    animated = true
//                }
//            }
            tableView.selectRowAtIndexPath(indexPath, animated: true /*animated*/, scrollPosition: UITableViewScrollPosition.Middle)
        default:
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let tableView = scrollView as UITableView
            switch tableView.tag {
            case BILLAMOUNTTAG:
                self.userIsDraggingBillAmountTableView = false
                tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            default:
                tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let tableView = scrollView as UITableView
        switch tableView.tag {
        case BILLAMOUNTTAG:
            tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            self.userIsDraggingBillAmountTableView = false
        default:
            tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        switch scrollView.tag {
        case BILLAMOUNTTAG:
            self.userIsDraggingBillAmountTableView = true
        default:
            println(self.userIsDraggingBillAmountTableView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as UITableView
        switch tableView.tag {
        case BILLAMOUNTTAG:
            let indexPath = self.indexPathInCenterOfTable(tableView)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            self.updateBillAmountText()
        default:
            if self.userIsDraggingBillAmountTableView == false {
                let indexPath = self.indexPathInCenterOfTable(tableView)
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                self.updateTipAmountText()
            }
        }
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
        var attributedString = NSAttributedString(string: "", attributes: self.totalAmountTextLabelAttributes)
        if let text = text {
            attributedString = NSAttributedString(string: text, attributes: self.totalAmountTextLabelAttributes)
        }
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
}

