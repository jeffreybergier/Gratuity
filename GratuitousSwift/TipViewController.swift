//
//  TipViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class TipViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet private weak var tipPercentageTextLabel: UILabel!
    @IBOutlet private weak var totalAmountTextLabel: UILabel!
    @IBOutlet private weak var billAmountTableView: GratuitousTableView!
    @IBOutlet private weak var tipAmountTableView: GratuitousTableView!
    @IBOutlet private weak var tipPercentageTextLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var totalAmountTextLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var billAmountTableViewTitleTextLabel: UILabel!
    @IBOutlet private weak var billAmountTableViewTitleTextLabelView: UIView!
    @IBOutlet private weak var tipAmountTableViewTitleTextLabel: UILabel!
    @IBOutlet private weak var tipAmountTableViewTitleTextLabelView: UIView!
    @IBOutlet private weak var billAmountSelectedSurroundView: UIView!
    @IBOutlet private weak var billAmountLowerGradientView: GratuitousGradientView!
    @IBOutlet private weak var selectedTableViewCellOutlineViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelContainerView: UIView!
    @IBOutlet private weak var tableContainerView: UIView!
    @IBOutlet private weak var settingsButton: UIButton!
    
    private let MAXBILLAMOUNT = 500
    private let MAXTIPAMOUNT = 250
    private let BILLAMOUNTTAG = 0
    private let TIPAMOUNTTAG = 1
    private let SMALLPHONECELLHEIGHT = CGFloat(50.0)
    private let TALLPHONECELLHEIGHT = CGFloat(60.0)
    private let MEDIUMPHONECELLHEIGHT = CGFloat(70.0)
    private let LARGEPHONECELLHEIGHT = CGFloat(74.0)
    
    private let currencyFormatter = GratuitousCurrencyFormatter()
    private let transitionManager = GratuitousTransitionManager()
    
    private var userDefaults = NSUserDefaults.standardUserDefaults()
    private var textSizeAdjustment: NSNumber = NSNumber(double: 0.0)
    private var billAmountsArray: [NSNumber] = []
    private var tipAmountsArray: [NSNumber] = []
    private var totalAmountTextLabelAttributes = [NSString(): NSObject()]
    private var tipPercentageTextLabelAttributes = [NSString(): NSObject()]
    private var didEndDeceleratingBillTable = false
    private var didEndDeceleratingTipTable = false
    private var tipTableCustomValueSet = false
    private var suggestedTipPercentage: Double = 0.0 {
        didSet {
            self.updateBillAmountText()
        }
    }
    
    //MARK: Handle View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "suggestedTipUpdatedOnDisk:", name: "suggestedTipValueUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeUpdateView:", name: "currencyFormatterReadyReloadView", object: nil)
        
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
        
        //prepare the primary view for the animation in
        self.labelContainerView.alpha = 0
        self.tableContainerView.alpha = 0
        
        //check screensize and set text side adjustment
        self.textSizeAdjustment = self.checkScreenHeightForTextSizeAdjuster()
        
        //was previously in viewWillAppear
        self.prepareTotalAmountTextLabel()
        self.prepareTipPercentageTextLabel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //on first load we need to load the view to what is written on disk.
        //also, for some reason, when the viewcontroller reappears after modal dismiss, it is not where I left, so we have to reload then as well.
        UIView.animateWithDuration(GratuitousAnimations.duration(),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                self.labelContainerView.alpha = 1.0
                self.tableContainerView.alpha = 1.0
            }, completion: nil)
        
        let billScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector: "scrollBillTableViewAtLaunch:", userInfo: nil, repeats: false)
        
        let tipScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.009, target: self, selector: "scrollTipTableViewAtLaunch:", userInfo: nil, repeats: false)
    }
    
    func scrollBillTableViewAtLaunch(timer: NSTimer?) {
        timer?.invalidate()
        
        //read the defaults off disk and move the bill amount to there
        let billUserDefaults = self.userDefaults.integerForKey("billIndexPathRow")
        var billIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if billUserDefaults == 0 {
            billIndexPath = NSIndexPath(forRow: 19, inSection: 0)
        } else {
            self.suggestedTipPercentage = self.userDefaults.doubleForKey("suggestedTipPercentage")
            let billIndexPathRow = self.userDefaults.integerForKey("billIndexPathRow")
            billIndexPath = NSIndexPath(forRow: billIndexPathRow, inSection: 0)
        }
        //println("Scrolling BillTableView to Row: \(billIndexPath.row)")
        self.didEndDeceleratingBillTable = true
        //have to do this ghetto two call method because just doing it once regularly caused things to not line up properly
        self.billAmountTableView.scrollToRowAtIndexPath(billIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        self.billAmountTableView.scrollToRowAtIndexPath(billIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func scrollTipTableViewAtLaunch(timer: NSTimer?) {
        timer?.invalidate()
        
        //if there is a preference for tip table, move the tip table to that
        let tipUserDefaults = self.userDefaults.integerForKey("tipIndexPathRow")
        var tipIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if tipUserDefaults == 0 {
            tipIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        } else {
            self.tipTableCustomValueSet = true
            let tipIndexPathRow = self.userDefaults.integerForKey("tipIndexPathRow")
            tipIndexPath = NSIndexPath(forRow: tipIndexPathRow, inSection: 0)
            //have to do this ghetto two call method because just doing it once regularly caused things to not line up properly
            self.tipAmountTableView.scrollToRowAtIndexPath(tipIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
            self.tipAmountTableView.scrollToRowAtIndexPath(tipIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            self.updateTipAmountText()
        }
    }
    
    //MARK: Handle User Input
    
    @IBAction func didTapBillAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        self.billAmountTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    @IBAction func didTapTipAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        self.tipAmountTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    @IBAction func willExitFromSegue (sender: UIStoryboardSegue){
        
    }
    
    //MARK: Handle Writing to Disk
    
    func suggestedTipUpdatedOnDisk(notification: NSNotification?) {
        let onDiskTipPercentage: NSNumber = self.userDefaults.doubleForKey("suggestedTipPercentage")
        self.suggestedTipPercentage = onDiskTipPercentage.doubleValue
    }
    
    private func writeBillIndexPathRowToDiskWithTableView(tableView: UITableView) {
        if !self.tipTableCustomValueSet {
            //println("Writing BillIndexPathRow to Disk: \(self.indexPathInCenterOfTable(tableView).row)")
            self.userDefaults.setInteger(self.indexPathInCenterOfTable(tableView).row, forKey: "billIndexPathRow")
            self.userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            self.userDefaults.synchronize()
        }
    }
    
    private func writeTipIndexPathRowToDiskWithTableView(tableView: UITableView) {
        if self.tipTableCustomValueSet {
            self.tipTableCustomValueSet = false
        } else {
            //println("Writing TipIndexPathRow to Disk: \(self.indexPathInCenterOfTable(tableView).row)")
            self.userDefaults.setInteger(self.indexPathInCenterOfTable(tableView).row, forKey: "tipIndexPathRow")
            self.userDefaults.synchronize()
        }
    }
    
    //MARK: Handle Updating the Big Labels
    
    private func updateBillAmountText() {
        let billAmountIndexPath = self.indexPathInCenterOfTable(self.billAmountTableView)
        if let billCell = self.billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as? GratuitousTableViewCell {
            let billAmount = billCell.billAmount
            let tipAmount: NSNumber = billAmount.doubleValue * self.suggestedTipPercentage
            let tipAmountRoundedString = NSString(format: "%.0f", tipAmount.doubleValue)
            var tipAmountRoundedNumber = NSNumber(double: tipAmountRoundedString.doubleValue)
            
            if tipAmountRoundedNumber.integerValue < 1 {
                tipAmountRoundedNumber = Double(1.0)
            }
            
            let tipIndexPath = NSIndexPath(forRow: tipAmountRoundedNumber.integerValue-1, inSection: 0)
            if !self.tipTableCustomValueSet {
                if !self.tipAmountTableView.scrollingState().isScrolling {
                    self.tipAmountTableView.scrollToRowAtIndexPath(tipIndexPath,
                        atScrollPosition: UITableViewScrollPosition.Middle,
                        animated: false)
                }
            }
            
            let totalAmount = billAmount.doubleValue + tipAmountRoundedNumber.doubleValue
            var totalAmountAttributedString = NSAttributedString()
            let currencyFormattedString = self.currencyFormatter.currencyFormattedString(NSNumber(double: totalAmount))
            //let currencyFormattedString = self.appDelegate.currencyFormatter.stringFromNumber(NSNumber(double: totalAmount))
            if let currencyFormattedString = currencyFormattedString {
                totalAmountAttributedString = NSAttributedString(string: currencyFormattedString, attributes: self.totalAmountTextLabelAttributes)
            } else {
                println("TipViewController: Failure to unwrap optional currencyFormattedString. You should never see this warning.")
                totalAmountAttributedString = NSAttributedString(string: NSString(format: "$%.0f", totalAmount), attributes: self.totalAmountTextLabelAttributes)
            }
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
                
                var totalAmountAttributedString = NSAttributedString()
                let currencyFormattedString = self.currencyFormatter.currencyFormattedString(NSNumber(double: totalAmount))
                //let currencyFormattedString = self.appDelegate.currencyFormatter.stringFromNumber(NSNumber(double: totalAmount))
                if let currencyFormattedString = currencyFormattedString {
                    totalAmountAttributedString = NSAttributedString(string: currencyFormattedString, attributes: self.totalAmountTextLabelAttributes)
                } else {
                    println("TipViewController: Failure to unwrap optional currencyFormattedString. You should never see this warning.")
                    totalAmountAttributedString = NSAttributedString(string: NSString(format: "$%.0f", totalAmount), attributes: self.totalAmountTextLabelAttributes)
                }
                let tipPercentageAttributedString = NSAttributedString(string: NSString(format: "%.0f%%", (tipAmountRoundedNumber.doubleValue/billAmount.doubleValue)*100), attributes: self.tipPercentageTextLabelAttributes)
                self.totalAmountTextLabel.attributedText = totalAmountAttributedString
                self.tipPercentageTextLabel.attributedText = tipPercentageAttributedString
            }
        }
    }
    
    func localeDidChangeUpdateView(notification: NSNotification) {
        self.updateBillAmountText()
    }
    
    //MARK: Handle View Controller Transitions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // this gets a reference to the screen that we're about to transition to
        let toViewController = segue.destinationViewController as UINavigationController
        
        // instead of using the default transition animation, we'll ask
        // the segue to use our custom TransitionManager object to manage the transition animation
        toViewController.transitioningDelegate = transitionManager
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ context in }, completion: {context in
            let selectedBillAmountIndexPath = self.billAmountTableView.indexPathForSelectedRow()
            let selectedTipAmountIndexPath = self.tipAmountTableView.indexPathForSelectedRow()
            
            if let indexPath = selectedBillAmountIndexPath {
                self.billAmountTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            }
            
            if let indexPath = selectedTipAmountIndexPath {
                self.tipAmountTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
        })
    }
    
    //MARK: Handle Table View User Input
    
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
            switch scrollView.tag {
            case self.BILLAMOUNTTAG:
                self.didEndDeceleratingBillTable = true
            default:
                self.didEndDeceleratingTipTable = true
            }
            self.scrollViewDidStopMovingForWateverReason(scrollView)
        }
    }

    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        switch scrollView.tag {
        case self.BILLAMOUNTTAG:
            self.didEndDeceleratingBillTable = true
        default:
            self.didEndDeceleratingTipTable = true
        }
        self.scrollViewDidStopMovingForWateverReason(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if self.didEndDeceleratingBillTable {
            self.didEndDeceleratingBillTable = false
        } else if self.didEndDeceleratingTipTable {
            self.didEndDeceleratingTipTable = false
        } else {
            self.scrollViewDidStopMovingForWateverReason(scrollView)
        }
    }
    
    private func scrollViewDidStopMovingForWateverReason(scrollView: UIScrollView) {
        let tableView = scrollView as GratuitousTableView
        
        tableView.isScrolling = false
        tableView.isUserInitiated = false
        
        switch tableView.tag {
        case self.BILLAMOUNTTAG:
            self.writeBillIndexPathRowToDiskWithTableView(tableView)
            tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        default:
            self.writeTipIndexPathRowToDiskWithTableView(tableView)
            tableView.selectRowAtIndexPath(self.indexPathInCenterOfTable(tableView), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if self.tipTableCustomValueSet {
            self.tipTableCustomValueSet = false
        }
        let tableView = scrollView as GratuitousTableView
        tableView.isScrolling = true
        tableView.isUserInitiated = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as GratuitousTableView
        
        switch tableView.tag {
        case BILLAMOUNTTAG:
            let indexPath = self.indexPathInCenterOfTable(tableView)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            self.updateBillAmountText()
        default:
            let indexPath = self.indexPathInCenterOfTable(tableView)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            self.updateTipAmountText()
        }
    }
    
    //MARK: Handle Table View Delegate DataSourceStuff
    
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
                if let cellCurrencyFormatter = cell.currencyFormatter {
                    // do nothing
                } else {
                    cell.currencyFormatter = self.currencyFormatter
                }
                cell.billAmount = self.billAmountsArray[indexPath.row]
                return cell
            default:
                let tipTableViewCellString = tableViewCellClass.stringByAppendingString("Tip")
                let cell = tableView.dequeueReusableCellWithIdentifier(tipTableViewCellString) as GratuitousTableViewCell
                if cell.textSizeAdjustment.doubleValue == 1.0 {
                    cell.textSizeAdjustment = self.textSizeAdjustment
                }
                if let cellCurrencyFormatter = cell.currencyFormatter {
                    // do nothing
                } else {
                    cell.currencyFormatter = self.currencyFormatter
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
    
    //MARK: View Controller Preferences
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    //MARK: Handle Text Size Adjustment and Label Attributed Strings
    
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
    
    //MARK: Handle View Going Away
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

