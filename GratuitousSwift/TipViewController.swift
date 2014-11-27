//
//  TipViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class TipViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    @IBOutlet private weak var largeTextWidthLandscapeOnlyConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelContainerView: UIView!
    @IBOutlet private weak var tableContainerView: UIView!
    @IBOutlet private weak var settingsButton: UIButton!
    
    private let MAXBILLAMOUNT = 2000
    private let MAXTIPAMOUNT = 1000
    private let EXTRACELLS: Int = {
        if UIScreen.mainScreen().traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            return 3
        } else {
            return 2
        }
    }()
    private let BILLAMOUNTTAG = 0
    private let TIPAMOUNTTAG = 1
    private let LARGETEXTWIDTH: CGFloat = 60
    
    private let currencyFormatter = GratuitousCurrencyFormatter()
    private let presentationTransitionerDelegate = GratuitousTransitioningDelegate()
    
    private var userDefaults = NSUserDefaults.standardUserDefaults()
    private var upperTextSizeAdjustment: NSNumber = NSNumber(double: 0.0)
    private var lowerTextSizeAdjustment: NSNumber = NSNumber(double: 0.0)
    private var billAmountsArray: [NSNumber] = []
    private var tipAmountsArray: [NSNumber] = []
    private var suggestedTipPercentage: Double = 0.0 {
        didSet {
            self.updateBillAmountText()
        }
    }
    private var totalAmountTextLabelAttributes = [NSString(): NSObject()]
    private var tipPercentageTextLabelAttributes = [NSString(): NSObject()]
    private var tipTableCustomValueSet = false
    
    //MARK: Handle View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "suggestedTipUpdatedOnDisk:", name: "suggestedTipValueUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeUpdateView:", name: "currencyFormatterReadyReloadView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "invertColorsDidChange:", name: UIAccessibilityInvertColorsStatusDidChangeNotification, object: nil)
        
        //prepare the arrays
        //the weird if statements add a couple extra 0's at the top and bottom of the array
        //this gives the tableview some padding as ContentInset doesn't work as expected
        //Once content inset is set (even when the top and bottom insets match) the tableview doesn't know where the "middle" is anymore.
        for i in 1 ... MAXBILLAMOUNT + (EXTRACELLS * 2) {
            if i < EXTRACELLS {
                self.billAmountsArray.append(NSNumber(double: Double(0)))
            } else if i > MAXBILLAMOUNT + EXTRACELLS {
                self.billAmountsArray.append(NSNumber(double: Double(0)))
            } else {
                self.billAmountsArray.append(NSNumber(double: Double(i-EXTRACELLS)))
            }
        }
        for i in 1 ... self.MAXTIPAMOUNT + (EXTRACELLS * 2) {
            if i < EXTRACELLS {
                self.tipAmountsArray.append(NSNumber(double: Double(0)))
            } else if i > MAXTIPAMOUNT + EXTRACELLS {
                self.tipAmountsArray.append(NSNumber(double: Double(0)))
            } else {
                self.tipAmountsArray.append(NSNumber(double: Double(i-EXTRACELLS)))
            }
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
        self.view.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.tipPercentageTextLabel.textColor = GratuitousUIConstant.lightTextColor()
        self.totalAmountTextLabel.textColor = GratuitousUIConstant.lightTextColor()
        self.tipAmountTableViewTitleTextLabel.textColor = GratuitousUIConstant.darkTextColor()
        self.billAmountTableViewTitleTextLabel.textColor = GratuitousUIConstant.darkTextColor()
        self.tipAmountTableViewTitleTextLabelView.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        self.billAmountTableViewTitleTextLabelView.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        
        //configure the text
        self.billAmountTableViewTitleTextLabel.text = NSLocalizedString("Amount on Bill", comment: "this is a text label displayed on the main page of the UI above the dollar amounts that user is supposed to select from for the cost of their restaurant bill.")
        self.tipAmountTableViewTitleTextLabel.text = NSLocalizedString("Suggested Tip", comment: "this is a text label displayed on the main page of the UI above the tip amounts. The app suggests a tip amount, but they can also override it. This should be text that describes this suggestion is just a suggestion.")
        
        //estimated row height
        self.billAmountTableView.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.tipAmountTableView.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        
        //prepare the cell select surrounds
        self.prepareCellSelectSurroundView()
        
        //prepare lower gradient view so its upside down
        self.billAmountLowerGradientView.isUpsideDown = true
        
        //prepare the primary view for the animation in
        self.labelContainerView.alpha = 0
        self.tableContainerView.alpha = 0
        
        //check screensize and set text side adjustment
        self.checkForScreenSizeConstraintAdjustments()
        self.lowerTextSizeAdjustment = GratuitousUIConstant.correctCellTextSize().textSizeAdjustment()
        self.selectedTableViewCellOutlineViewHeightConstraint.constant = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.largeTextWidthLandscapeOnlyConstraint.constant = GratuitousUIConstant.largeTextLandscapeConstant()
        
        //prepare the settings button
        self.prepareSettingsButton()
        
        //was previously in viewWillAppear
        self.prepareTotalAmountTextLabel()
        self.prepareTipPercentageTextLabel()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //on first load we need to load the view to what is written on disk.
        //also, for some reason, when the viewcontroller reappears after modal dismiss, it is not where I left, so we have to reload then as well.
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                self.labelContainerView.alpha = 1.0
                self.tableContainerView.alpha = 1.0
            }, completion: nil)
        
        let billScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "scrollBillTableViewAtLaunch:", userInfo: nil, repeats: false)
        let tipScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "scrollTipTableViewAtLaunch:", userInfo: nil, repeats: false)
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
        //have to do this ghetto two call method because just doing it once regularly caused things to not line up properly
        self.billAmountTableView.scrollToRowAtIndexPath(billIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        self.billAmountTableView.scrollToRowAtIndexPath(billIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        
        //make sure the big labels are presented
        self.bigTextLabelsShouldPresent(true)
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
        //make sure the big labels are presented
        self.bigTextLabelsShouldPresent(true)
    }
    
    private func prepareCellSelectSurroundView() {
        self.billAmountSelectedSurroundView.backgroundColor = UIColor.clearColor()
        self.billAmountSelectedSurroundView.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.billAmountSelectedSurroundView.layer.cornerRadius = 0.0
        self.billAmountSelectedSurroundView.layer.borderColor = GratuitousUIConstant.lightBackgroundColor().CGColor
        self.billAmountSelectedSurroundView.backgroundColor = GratuitousUIConstant.lightBackgroundColor().colorWithAlphaComponent(0.15)
    }
    
    private func prepareSettingsButton() {
        self.settingsButton.setImage(nil, forState: UIControlState.Normal)
        self.settingsButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.settingsButton.setTitle(NSLocalizedString("Settings", comment: "Settings"), forState: UIControlState.Normal)
        self.settingsButton.sizeToFit()
        if let path = NSBundle.mainBundle().pathForResource("settingsIcon", ofType:"pdf") {
            let image = ImageFromPDFFileWithHeight(path, self.settingsButton.frame.size.height).imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.settingsButton.setTitle("", forState: UIControlState.Normal)
            self.settingsButton.setImage(image, forState: UIControlState.Normal)
            self.settingsButton.sizeToFit()
        }
    }
    
    //MARK: Handle User Input
    
    @IBAction func didTapBillAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        self.billAmountTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    @IBAction func didTapTipAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        self.tipAmountTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        let billScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "scrollBillTableViewAtLaunch:", userInfo: nil, repeats: false)
        let tipScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "scrollTipTableViewAtLaunch:", userInfo: nil, repeats: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let settingsViewController = segue.destinationViewController as? UINavigationController
        if let settingsViewController = settingsViewController {
            settingsViewController.transitioningDelegate = self.presentationTransitionerDelegate
            settingsViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        }
    }

    private func bigTextLabelsShouldPresent(presenting: Bool) {
        var transform = presenting ? CGAffineTransformIdentity : CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8)
        var alpha: CGFloat = presenting ? 1.0 : 0.5
        if self.presentedViewController != nil {
            //if the view controller is presenting something, I want these values to always be big
            transform = CGAffineTransformIdentity
            alpha = 1.0
        }
        
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: presenting ? 0.05 : 0.05,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 1.9,
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.labelContainerView.transform = transform
                self.labelContainerView.alpha = alpha
            },
            completion: { finished in
                //do nothing
        })
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
            
            let tipIndexPath = NSIndexPath(forRow: tipAmountRoundedNumber.integerValue + EXTRACELLS - 1, inSection: 0)
            if !self.tipTableCustomValueSet {
                if !self.tipAmountTableView.isScrolling {
                    self.tipAmountTableView.scrollToRowAtIndexPath(tipIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
                }
            }
            
            let totalAmount = billAmount.doubleValue + tipAmountRoundedNumber.doubleValue
            var totalAmountAttributedString = NSAttributedString()
            let currencyFormattedString = self.currencyFormatter.currencyFormattedString(NSNumber(double: totalAmount))
            if let currencyFormattedString = currencyFormattedString {
                totalAmountAttributedString = NSAttributedString(string: currencyFormattedString, attributes: self.totalAmountTextLabelAttributes)
            } else {
                println("TipViewController: Failure to unwrap optional currencyFormattedString. You should never see this warning.")
                totalAmountAttributedString = NSAttributedString(string: NSString(format: "$%.0f", totalAmount), attributes: self.totalAmountTextLabelAttributes)
            }
            let tipPercentageString = NSString(format: "%.0f%%", (tipAmountRoundedNumber.doubleValue/billAmount.doubleValue)*100)
            let tipPercentageAttributedString = tipPercentageString == "inf%" ? NSAttributedString(string: "100%", attributes: self.tipPercentageTextLabelAttributes) : NSAttributedString(string: tipPercentageString, attributes: self.tipPercentageTextLabelAttributes)
            self.totalAmountTextLabel.attributedText = totalAmountAttributedString
            self.tipPercentageTextLabel.attributedText = tipPercentageAttributedString
        }
//        println("Upper: \(self.upperTextSizeAdjustment)")
//        println("Lower: \(self.lowerTextSizeAdjustment)")
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
            self.scrollViewDidStopMovingForWhateverReason(scrollView)
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollViewDidStopMovingForWhateverReason(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.scrollViewDidStopMovingForWhateverReason(scrollView)
    }
    
    private func scrollViewDidStopMovingForWhateverReason(scrollView: UIScrollView) {
        let tableView = scrollView as? GratuitousTableView
        
        if let tableView = tableView {
            tableView.isScrolling = false
            switch tableView.tag {
                //both of these have to be false to animate because if the rowheight is over 63, the animation doesn't work right and stops the tableviewfrom scrolling.
            case self.BILLAMOUNTTAG:
                let indexPath = self.indexPathInCenterOfTable(tableView)
                if indexPath.row > EXTRACELLS - 1 {
                    if indexPath.row > MAXBILLAMOUNT + EXTRACELLS - 1 {
                        tableView.selectRowAtIndexPath(NSIndexPath(forRow: MAXBILLAMOUNT + EXTRACELLS - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                    } else {
                        self.writeBillIndexPathRowToDiskWithTableView(tableView)
                        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                    }
                } else {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: EXTRACELLS, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                }
            default:
                let indexPath = self.indexPathInCenterOfTable(tableView)
                if indexPath.row > EXTRACELLS - 1 {
                    if indexPath.row > MAXTIPAMOUNT + EXTRACELLS - 1 {
                        tableView.selectRowAtIndexPath(NSIndexPath(forRow: MAXTIPAMOUNT + EXTRACELLS - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                    } else {
                        self.writeTipIndexPathRowToDiskWithTableView(tableView)
                        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                    }
                } else {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: EXTRACELLS, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                }
            }
            self.bigTextLabelsShouldPresent(true)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if self.tipTableCustomValueSet {
            self.tipTableCustomValueSet = false
        }
        let tableView = scrollView as GratuitousTableView
        tableView.isScrolling = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as GratuitousTableView
        
        self.bigTextLabelsShouldPresent(false)
        
        switch tableView.tag {
        case BILLAMOUNTTAG:
            //these lines were needed when the cells needed to do something when the tableview was scrolling, but its no longer needed
            //let indexPath = self.indexPathInCenterOfTable(tableView)
            //tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            self.updateBillAmountText()
        default:
            //these lines were needed when the cells needed to do something when the tableview was scrolling, but its no longer needed
            //let indexPath = self.indexPathInCenterOfTable(tableView)
            //tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
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
        if tableView.tag == BILLAMOUNTTAG {
            //println("Just got a request to retrieve this row dollar amount = $\(indexPath.row+1)")
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
                cell.textSizeAdjustment = self.lowerTextSizeAdjustment
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
                cell.textSizeAdjustment = self.lowerTextSizeAdjustment
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
        var rowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        
        return rowHeight
    }
    
    //MARK: View Controller Preferences
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if UIAccessibilityIsInvertColorsEnabled() {
            return UIStatusBarStyle.Default
        } else {
            return UIStatusBarStyle.LightContent
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    //MARK: Handle Text Size Adjustment and Label Attributed Strings
    
    func systemTextSizeDidChange(notification: NSNotification) {
        //adjust text size
        self.lowerTextSizeAdjustment = GratuitousUIConstant.correctCellTextSize().textSizeAdjustment()
        self.selectedTableViewCellOutlineViewHeightConstraint.constant = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.largeTextWidthLandscapeOnlyConstraint.constant = GratuitousUIConstant.largeTextLandscapeConstant()
        
        //estimated row height
        self.billAmountTableView.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.tipAmountTableView.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        
        //update the view
        self.prepareSettingsButton()
        self.billAmountTableView.reloadData()
        self.tipAmountTableView.reloadData()
    }
    
    func invertColorsDidChange(notification: NSNotification) {
        //configure color of view
        self.view.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.tipPercentageTextLabel.textColor = GratuitousUIConstant.lightTextColor()
        self.totalAmountTextLabel.textColor = GratuitousUIConstant.lightTextColor()
        self.tipAmountTableViewTitleTextLabel.textColor = GratuitousUIConstant.darkTextColor()
        self.billAmountTableViewTitleTextLabel.textColor = GratuitousUIConstant.darkTextColor()
        self.tipAmountTableViewTitleTextLabelView.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        self.billAmountTableViewTitleTextLabelView.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        
        //change the status bar
        //this line of code doesn't actually work, but maybe it will some day?
        UIApplication.sharedApplication().statusBarStyle = self.preferredStatusBarStyle()
        
        //update the surround view
        self.prepareCellSelectSurroundView()
        
        //update the colors for the text attributes
        self.totalAmountTextLabelAttributes["NSColor"] = GratuitousUIConstant.lightTextColor()
        self.tipPercentageTextLabelAttributes["NSColor"] = GratuitousUIConstant.lightTextColor()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        //this line stops a bug with the transforms on rotation
        self.view.transform = CGAffineTransformIdentity
        
        coordinator.animateAlongsideTransition(nil, completion: { finished in
            
            let billScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "scrollBillTableViewAtLaunch:", userInfo: nil, repeats: false)
            let tipScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "scrollTipTableViewAtLaunch:", userInfo: nil, repeats: false)
        })
    }
    
    private func checkForScreenSizeConstraintAdjustments() {
        let nothing = GratuitousUIConstant.actualScreenSizeBasedOnWidth()
        switch GratuitousUIConstant.actualScreenSizeBasedOnWidth() {
        case .iPhone4or5:
            self.tipPercentageTextLabelTopConstraint.constant = -15.0
            self.totalAmountTextLabelBottomConstraint.constant = -12.0
            self.upperTextSizeAdjustment = Double(0.76)
        case .iPhone6:
            self.tipPercentageTextLabelTopConstraint.constant = -10.0
            self.totalAmountTextLabelBottomConstraint.constant = -10.0
            self.upperTextSizeAdjustment = Double(0.85)
        case .iPhone6Plus:
            self.tipPercentageTextLabelTopConstraint.constant = -20.0
            self.totalAmountTextLabelBottomConstraint.constant = -10.0
            self.upperTextSizeAdjustment = Double(1.0)
        case .iPad:
            self.tipPercentageTextLabelTopConstraint.constant = -25.0
            self.totalAmountTextLabelBottomConstraint.constant = -5.0
            self.upperTextSizeAdjustment = Double(1.3)
        }
    }
    
    private func prepareTotalAmountTextLabel() {
        if let originalFont = GratuitousUIConstant.originalFontForTotalAmountTextLabel() {
            self.totalAmountTextLabel.font = originalFont
        }
        let font = self.totalAmountTextLabel.font.fontWithSize(self.totalAmountTextLabel.font.pointSize * CGFloat(self.upperTextSizeAdjustment.floatValue))
        let textColor = self.totalAmountTextLabel.textColor
        let text = self.totalAmountTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousUIConstant.textShadowColor()
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
        if let originalFont = GratuitousUIConstant.originalFontForTipPercentageTextLabel() {
            self.tipPercentageTextLabel.font = originalFont
        }
        let font = self.tipPercentageTextLabel.font.fontWithSize(self.tipPercentageTextLabel.font.pointSize * CGFloat(self.upperTextSizeAdjustment.floatValue))
        let textColor = self.tipPercentageTextLabel.textColor
        let text = self.tipPercentageTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousUIConstant.textShadowColor()
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

