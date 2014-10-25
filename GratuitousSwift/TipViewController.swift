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
    @IBOutlet weak private var billAmountTableView: GratuitousTableView!
    @IBOutlet weak private var tipAmountTableView: GratuitousTableView!
    @IBOutlet weak private var tipPercentageTextLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var totalAmountTextLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var billAmountTableViewTitleTextLabel: UILabel!
    @IBOutlet weak private var billAmountTableViewTitleTextLabelView: UIView!
    @IBOutlet weak private var tipAmountTableViewTitleTextLabel: UILabel!
    @IBOutlet weak private var tipAmountTableViewTitleTextLabelView: UIView!
    @IBOutlet weak var billAmountSelectedSurroundView: UIView!
    @IBOutlet weak var billAmountLowerGradientView: GratuitousGradientView!
    @IBOutlet weak var selectedTableViewCellOutlineViewHeightConstraint: NSLayoutConstraint!
    
    private let MAXBILLAMOUNT = 500
    private let MAXTIPAMOUNT = 250
    private let BILLAMOUNTTAG = 0
    private let TIPAMOUNTTAG = 1
    private let IDEALTIPPERCENTAGE = 0.2
    private let SMALLPHONECELLHEIGHT = CGFloat(50.0)
    private let TALLPHONECELLHEIGHT = CGFloat(60.0)
    private let MEDIUMPHONECELLHEIGHT = CGFloat(70.0)
    private let LARGEPHONECELLHEIGHT = CGFloat(74.0)
    
    private var textSizeAdjustment: NSNumber = NSNumber(double: 0.0)
    private var billAmountsArray: [NSNumber] = []
    private var tipAmountsArray: [NSNumber] = []
    private var totalAmountTextLabelAttributes = [NSString(): NSObject()]
    private var tipPercentageTextLabelAttributes = [NSString(): NSObject()]
    
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
        if let tableViewCellClass = NSStringFromClass(GratuitousTableViewCell).componentsSeparatedByString(".").last {
            let billTableViewCellString = tableViewCellClass.stringByAppendingString("Bill")
            self.billAmountTableView.configureTableViewWithCellType(tableViewCellClass, AndCellIdentifier: billTableViewCellString, AndTag: self.BILLAMOUNTTAG, AndViewControllerDelegate: self)
            
            let tipTableViewCellString = tableViewCellClass.stringByAppendingString("Tip")
            self.tipAmountTableView.configureTableViewWithCellType(tableViewCellClass, AndCellIdentifier: tipTableViewCellString, AndTag: self.TIPAMOUNTTAG, AndViewControllerDelegate: self)
        } else {
            println("TipViewController: You should never see this. If you see this the tables were not configured correctly because an optional unwrap failed")
        }
        
        //configure color of view
        self.view.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.tipPercentageTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        self.totalAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        self.tipAmountTableViewTitleTextLabel.textColor = GratuitousColorSelector.darkTextColor()
        self.billAmountTableViewTitleTextLabel.textColor = GratuitousColorSelector.darkTextColor()
        self.tipAmountTableViewTitleTextLabelView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
        self.billAmountTableViewTitleTextLabelView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
        
        //prepare the cell select surrounds
        self.billAmountSelectedSurroundView.backgroundColor = UIColor.clearColor()
        self.billAmountSelectedSurroundView.layer.borderWidth = 3.0
        self.billAmountSelectedSurroundView.layer.cornerRadius = 0.0
        self.billAmountSelectedSurroundView.layer.borderColor = GratuitousColorSelector.lightBackgroundColor().CGColor
        
        //prepare lower gradient view so its upside down
        self.billAmountLowerGradientView.isUpsideDown = true
        
        //temp timer to find when things are dragging
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.35, target: self, selector: "draggingTimer:", userInfo: nil, repeats: true)
        
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
        
        let indexPath = NSIndexPath(forRow: 19, inSection: 0)
        self.billAmountTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
    }
    
    func draggingTimer(timer: NSTimer) {
        //println(self.billAmountTableView.scrollingState())
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
        if let billCell = self.billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as? GratuitousTableViewCell {
            let billAmount = billCell.billAmount
            let tipAmount: NSNumber = billAmount.doubleValue * self.IDEALTIPPERCENTAGE
            let tipAmountRoundedString = NSString(format: "%.0f", tipAmount.doubleValue)
            var tipAmountRoundedNumber = NSNumber(double: tipAmountRoundedString.doubleValue)
            
            if tipAmountRoundedNumber.integerValue < 1 {
                tipAmountRoundedNumber = Double(1.0)
            }
            
            let tipIndexPath = NSIndexPath(forRow: tipAmountRoundedNumber.integerValue-1, inSection: 0)
            if !self.tipAmountTableView.scrollingState().isScrolling {
                self.tipAmountTableView.selectRowAtIndexPath(tipIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            }
            
            let totalAmount = billAmount.doubleValue + tipAmountRoundedNumber.doubleValue
            let totalAmountAttributedString = NSAttributedString(string: NSString(format: "$%.0f", totalAmount), attributes: self.totalAmountTextLabelAttributes)
            let tipPercentageAttributedString = NSAttributedString(string: NSString(format: "%.0f%%", (tipAmountRoundedNumber.doubleValue/billAmount.doubleValue)*100), attributes: self.tipPercentageTextLabelAttributes)
            self.totalAmountTextLabel.attributedText = totalAmountAttributedString
            self.tipPercentageTextLabel.attributedText = tipPercentageAttributedString
        }
    }
    
    private func updateTipAmountText() {
        let billAmountIndexPath = self.indexPathInCenterOfTable(self.billAmountTableView)
        if let billCell = self.billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as? GratuitousTableViewCell {
            let billAmount = billCell.billAmount
            
            let tipAmountIndexPath = self.indexPathInCenterOfTable(self.tipAmountTableView)
            if let tipCell = self.tipAmountTableView.cellForRowAtIndexPath(tipAmountIndexPath) as? GratuitousTableViewCell {
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
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "didRotateTimer:", userInfo: nil, repeats: false)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //traitcollection did change isn't called on ipads because their size class never changes. This works around that issue.
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.didRotateTimer(nil)
        }
    }
    
    func didRotateTimer(timer: NSTimer?) {
        timer?.invalidate()
        
        let selectedBillAmountIndexPath = self.billAmountTableView.indexPathForSelectedRow()
        let selectedTipAmountIndexPath = self.tipAmountTableView.indexPathForSelectedRow()
        
        if let indexPath = selectedBillAmountIndexPath {
            self.billAmountTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        }
        
        if let indexPath = selectedTipAmountIndexPath {
            self.tipAmountTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    
    @IBAction func didTapBillAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        self.billAmountTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Top)
    }
    
    @IBAction func didTapTipAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        //self.tipAmountTableView.isScrolling = true
        self.tipAmountTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch tableView.tag {
        case BILLAMOUNTTAG:
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        default:
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let tableView = scrollView as GratuitousTableView
            
            tableView.isScrolling = false
            tableView.isUserInitiated = false
            
            switch tableView.tag {
            case BILLAMOUNTTAG:
                tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            default:
                tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let tableView = scrollView as GratuitousTableView
        
        tableView.isScrolling = false
        tableView.isUserInitiated = false
        
        switch tableView.tag {
        case BILLAMOUNTTAG:
            tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        default:
            tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let tableView = scrollView as GratuitousTableView
        tableView.isScrolling = true
        tableView.isUserInitiated = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as GratuitousTableView
        
        tableView.isUserInitiated = false
        
        switch tableView.tag {
        case BILLAMOUNTTAG:
            let indexPath = self.indexPathInCenterOfTable(tableView)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            self.updateBillAmountText()
        default:
            //if self.billAmountTableView.dragging == false {
                let indexPath = self.indexPathInCenterOfTable(tableView)
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                self.updateTipAmountText()
            //}
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch tableView.tag {
        case BILLAMOUNTTAG:
            count = self.billAmountsArray.count
        default:
            count = self.tipAmountsArray.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let tableViewCellClass = NSStringFromClass(GratuitousTableViewCell).componentsSeparatedByString(".").last {
            switch tableView.tag {
            case BILLAMOUNTTAG:
                let billTableViewCellString = tableViewCellClass.stringByAppendingString("Bill")
                let cell = tableView.dequeueReusableCellWithIdentifier(billTableViewCellString) as GratuitousTableViewCell
                if cell.textSizeAdjustment.doubleValue == 1.0 {
                    cell.textSizeAdjustment = self.textSizeAdjustment
                }
                cell.billAmount = self.billAmountsArray[indexPath.row]
                return cell
            default:
                let tipTableViewCellString = tableViewCellClass.stringByAppendingString("Tip")
                let cell = tableView.dequeueReusableCellWithIdentifier(tipTableViewCellString) as GratuitousTableViewCell
                if cell.textSizeAdjustment.doubleValue == 1.0 {
                    cell.textSizeAdjustment = self.textSizeAdjustment
                }
                cell.billAmount = self.tipAmountsArray[indexPath.row]
                return cell
            }
        } else {
            println("TipViewController: This should never print. A new cell blank cell was created for no reason because of an optional unwrap failing")
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight = CGFloat(self.MEDIUMPHONECELLHEIGHT)
        
        if self.textSizeAdjustment.doubleValue < 0.8 {
            rowHeight = self.SMALLPHONECELLHEIGHT
        } else if self.textSizeAdjustment.doubleValue < 1.0 {
            rowHeight = self.TALLPHONECELLHEIGHT
        }
        
        return rowHeight
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
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.LARGEPHONECELLHEIGHT
                textSizeAdjustment = Double(1.1)
            } else if UIScreen.mainScreen().bounds.size.height > 666 {
                self.tipPercentageTextLabelTopConstraint.constant = -20.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.MEDIUMPHONECELLHEIGHT
                textSizeAdjustment = Double(1.0)
            } else if UIScreen.mainScreen().bounds.size.height > 567 {
                self.tipPercentageTextLabelTopConstraint.constant = -10.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.TALLPHONECELLHEIGHT
                textSizeAdjustment = Double(0.85)
            } else if UIScreen.mainScreen().bounds.size.height > 479 {
                self.tipPercentageTextLabelTopConstraint.constant = -15.0
                self.totalAmountTextLabelBottomConstraint.constant = -12.0
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.SMALLPHONECELLHEIGHT
                textSizeAdjustment = Double(0.76)
            }
        } else {
            if UIScreen.mainScreen().bounds.size.width > 735 {
                self.tipPercentageTextLabelTopConstraint.constant = -25.0
                self.totalAmountTextLabelBottomConstraint.constant = -5.0
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.LARGEPHONECELLHEIGHT
                textSizeAdjustment = Double(1.1)
            } else if UIScreen.mainScreen().bounds.size.width > 666 {
                self.tipPercentageTextLabelTopConstraint.constant = -20.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.MEDIUMPHONECELLHEIGHT
                textSizeAdjustment = Double(1.0)
            } else if UIScreen.mainScreen().bounds.size.width > 567 {
                self.tipPercentageTextLabelTopConstraint.constant = -10.0
                self.totalAmountTextLabelBottomConstraint.constant = -10.0
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.TALLPHONECELLHEIGHT
                textSizeAdjustment = Double(0.85)
            } else if UIScreen.mainScreen().bounds.size.width > 479 {
                self.tipPercentageTextLabelTopConstraint.constant = -15.0
                self.totalAmountTextLabelBottomConstraint.constant = -12.0
                self.selectedTableViewCellOutlineViewHeightConstraint.constant = self.SMALLPHONECELLHEIGHT
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

