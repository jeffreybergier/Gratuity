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
    @IBOutlet private weak var billAmountTableView: UITableView!
    @IBOutlet private weak var tipAmountTableView: UITableView!
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
    
    private struct PrivateConstants {
        static let MaxBillAmount = 2000
        static let MaxTipAmount = 1000
        static let ExtraCells: Int = {
            if UIScreen.mainScreen().traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                return 3
            } else {
                return 2
            }
        }()
    }
    
    private enum TableTag: Int {
        case BillAmount = 0, TipAmount
    }

    //private let LARGETEXTWIDTH: CGFloat = 60
    
    private let tableViewCellClass = GratuitousTableViewCell.description().componentsSeparatedByString(".").last! //should crash if this is nil
    private let billTableViewCellString = GratuitousTableViewCell.description().componentsSeparatedByString(".").last! + "Bill"
    private let tipTableViewCellString = GratuitousTableViewCell.description().componentsSeparatedByString(".").last! + "Tip"
    
    private let currencyFormatter = GratuitousCurrencyFormatter()
    private let presentationTransitionerDelegate = GratuitousTransitioningDelegate()
    
    private weak var defaultsManager = (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).defaultsManager
    private var upperTextSizeAdjustment: CGFloat = 0.0
    private var lowerTextSizeAdjustment: CGFloat = 0.0
    private var billAmountsArray: [Int] = []
    private var tipAmountsArray: [Int] = []
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
        
        #if DEBUG
            // add a crash button to the view to test crashlytics
            let crashButton = UIButton(frame: CGRect(x: 12, y: 20, width: 10, height: 10))
            let viewDictionary = ["crashButton" : crashButton]
            crashButton.setTitle("Cause Crash", forState: UIControlState.Normal)
            crashButton.addTarget(self, action: "causeCrash: InTipViewController:", forControlEvents: UIControlEvents.TouchUpInside)
            crashButton.sizeToFit()
            self.view.addSubview(crashButton)
        #endif
        
        // configure notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "suggestedTipUpdatedOnDisk:", name: "suggestedTipValueUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeUpdateView:", name: "currencyFormatterReadyReloadView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "invertColorsDidChange:", name: UIAccessibilityInvertColorsStatusDidChangeNotification, object: nil)
        
        //prepare the arrays
        //the weird if statements add a couple extra 0's at the top and bottom of the array
        //this gives the tableview some padding as ContentInset doesn't work as expected
        //Once content inset is set (even when the top and bottom insets match) the tableview doesn't know where the "middle" is anymore.
        for i in 1 ... PrivateConstants.MaxBillAmount + (PrivateConstants.ExtraCells * 2) {
            if i < PrivateConstants.ExtraCells {
                self.billAmountsArray.append(0)
            } else if i > PrivateConstants.MaxBillAmount + PrivateConstants.ExtraCells {
                self.billAmountsArray.append(0)
            } else {
                self.billAmountsArray.append(i - PrivateConstants.ExtraCells)
            }
        }
        for i in 1 ... PrivateConstants.MaxTipAmount + (PrivateConstants.ExtraCells * 2) {
            if i < PrivateConstants.ExtraCells {
                self.tipAmountsArray.append(0)
            } else if i > PrivateConstants.MaxTipAmount + PrivateConstants.ExtraCells {
                self.tipAmountsArray.append(0)
            } else {
                self.tipAmountsArray.append(i - PrivateConstants.ExtraCells)
            }
        }
        
        //prepare the tableviews
        
        self.billAmountTableView.delegate = self
        self.billAmountTableView.dataSource = self
        self.billAmountTableView.tag = TableTag.BillAmount.rawValue
        self.billAmountTableView.estimatedRowHeight = 76.0
        self.billAmountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.billAmountTableView.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.billAmountTableView.showsVerticalScrollIndicator = false
        self.billAmountTableView.registerNib(UINib(nibName: self.tableViewCellClass, bundle: nil), forCellReuseIdentifier: billTableViewCellString)
        
        self.tipAmountTableView.delegate = self
        self.tipAmountTableView.dataSource = self
        self.tipAmountTableView.tag = TableTag.TipAmount.rawValue
        self.tipAmountTableView.estimatedRowHeight = 76.0
        self.tipAmountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tipAmountTableView.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.tipAmountTableView.showsVerticalScrollIndicator = false
        self.tipAmountTableView.registerNib(UINib(nibName: self.tableViewCellClass, bundle: nil), forCellReuseIdentifier: tipTableViewCellString)
        
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
        let billUserDefaults = self.defaultsManager!.billIndexPathRow
        let suggestedTipPercentage = self.defaultsManager!.suggestedTipPercentage
        
        let billIndexPath = NSIndexPath(forRow: billUserDefaults, inSection: 0)
        self.suggestedTipPercentage = suggestedTipPercentage

        //have to do this ghetto two call method because just doing it once regularly caused things to not line up properly
        self.billAmountTableView.scrollToRowAtIndexPath(billIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        
        //make sure the big labels are presented
        self.bigTextLabelsShouldPresent(true)
    }
    
    func scrollTipTableViewAtLaunch(timer: NSTimer?) {
        timer?.invalidate()
        
        //if there is a preference for tip table, move the tip table to that
        let tipUserDefaults = self.defaultsManager!.tipIndexPathRow //self.userDefaults.integerForKey("tipIndexPathRow")
        let tipIndexPath = NSIndexPath(forRow: tipUserDefaults, inSection: 0)
        if tipIndexPath.row != 0 {
            self.tipTableCustomValueSet = true
            //have to do this ghetto two call method because just doing it once regularly caused things to not line up properly
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
        let billScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "scrollBillTableViewAtLaunch:", userInfo: nil, repeats: false)
        let tipScrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "scrollTipTableViewAtLaunch:", userInfo: nil, repeats: false)
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
        let onDiskTipPercentage: NSNumber = self.defaultsManager!.suggestedTipPercentage
        self.suggestedTipPercentage = onDiskTipPercentage.doubleValue
    }
    
    private func writeBillIndexPathRowToDiskWithTableView(tableView: UITableView) {
        if !self.tipTableCustomValueSet {
            self.defaultsManager!.billIndexPathRow = self.indexPathInCenterOfTable(tableView).row
            self.defaultsManager!.tipIndexPathRow = 0
        }
    }
    
    private func writeTipIndexPathRowToDiskWithTableView(tableView: UITableView) {
        if self.tipTableCustomValueSet {
            self.tipTableCustomValueSet = false
        } else {
            self.defaultsManager!.tipIndexPathRow = self.indexPathInCenterOfTable(tableView).row
        }
    }
    
    //MARK: Handle Updating the Big Labels
    
    private func updateBillAmountText() {
        let billAmountIndexPath = self.indexPathInCenterOfTable(self.billAmountTableView)
        if let billCell = self.billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as? GratuitousTableViewCell {
            if billCell.billAmount > 0 {
                let billAmount = billCell.billAmount
                let tipAmount = Int(round((Double(billAmount) * self.suggestedTipPercentage)))
                let tipPercentage = Int(round(Double(tipAmount) / Double(billAmount) * 100))
                
                let tipIndexPath = NSIndexPath(forRow: tipAmount + PrivateConstants.ExtraCells - 1, inSection: 0)
//                if !self.tipTableCustomValueSet {
//                    if !self.tipAmountTableView.isScrolling {
                        self.tipAmountTableView.scrollToRowAtIndexPath(tipIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
//                    }
//                }
                
                let totalAmount = billAmount + tipAmount
                var totalAmountAttributedString = NSAttributedString()
                let currencyFormattedString = self.currencyFormatter.currencyFormattedString(totalAmount)
                totalAmountAttributedString = NSAttributedString(string: currencyFormattedString, attributes: self.totalAmountTextLabelAttributes)
                
                let tipPercentageString = "\(tipPercentage)%"
                let tipPercentageAttributedString = tipPercentageString == "inf%" ? NSAttributedString(string: "100%", attributes: self.tipPercentageTextLabelAttributes) : NSAttributedString(string: tipPercentageString, attributes: self.tipPercentageTextLabelAttributes)
                
                self.totalAmountTextLabel.attributedText = totalAmountAttributedString
                self.tipPercentageTextLabel.attributedText = tipPercentageAttributedString
            }
        }
    }
    
    private func updateTipAmountText() {
        let billAmountIndexPath = self.indexPathInCenterOfTable(self.billAmountTableView)
        let tipAmountIndexPath = self.indexPathInCenterOfTable(self.tipAmountTableView)
        
        if let billCell = self.billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as? GratuitousTableViewCell, tipCell = self.tipAmountTableView.cellForRowAtIndexPath(tipAmountIndexPath) as? GratuitousTableViewCell {
            if billCell.billAmount > 0 {
                let billAmount = billCell.billAmount
                let tipAmount = tipCell.billAmount
                let totalAmount = billAmount + tipAmount
                let tipPercentage = Int(round(Double(tipAmount) / Double(billAmount) * 100))
                
                let currencyFormattedString = self.currencyFormatter.currencyFormattedString(totalAmount)
                let totalAmountAttributedString = NSAttributedString(string: currencyFormattedString, attributes: self.totalAmountTextLabelAttributes)
                let tipPercentageAttributedString = NSAttributedString(string: "\(tipPercentage)%", attributes: self.tipPercentageTextLabelAttributes)
                
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
        if let tableTagEnum = TableTag(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .BillAmount:
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            case .TipAmount:
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
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
    
    private func scrollViewDidStopMovingForWhateverReason(scrollView: UIScrollView) {
        let tableView = scrollView as? UITableView
        
        if let tableView = tableView, let tableTagEnum = TableTag(rawValue: tableView.tag) {
            //tableView.isScrolling = false
            switch tableTagEnum {
            case .BillAmount:
                let indexPath = self.indexPathInCenterOfTable(tableView)
                if indexPath.row > PrivateConstants.ExtraCells - 1 {
                    if indexPath.row > PrivateConstants.MaxBillAmount + PrivateConstants.ExtraCells - 1 {
                        tableView.selectRowAtIndexPath(NSIndexPath(forRow: PrivateConstants.MaxBillAmount + PrivateConstants.ExtraCells - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                    } else {
                        self.writeBillIndexPathRowToDiskWithTableView(tableView)
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                    }
                } else {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: PrivateConstants.ExtraCells, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                }
            case .TipAmount:
                let indexPath = self.indexPathInCenterOfTable(tableView)
                if indexPath.row > PrivateConstants.ExtraCells - 1 {
                    if indexPath.row > PrivateConstants.MaxTipAmount + PrivateConstants.ExtraCells - 1 {
                        tableView.selectRowAtIndexPath(NSIndexPath(forRow: PrivateConstants.MaxTipAmount + PrivateConstants.ExtraCells - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                    } else {
                        self.writeTipIndexPathRowToDiskWithTableView(tableView)
                        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                    }
                } else {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: PrivateConstants.ExtraCells, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                }
            }
            self.bigTextLabelsShouldPresent(true)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if self.tipTableCustomValueSet {
            self.tipTableCustomValueSet = false
        }
        if let tableView = scrollView as? UITableView {
            //tableView.isScrolling = true
        }
        self.bigTextLabelsShouldPresent(false)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let tableView = scrollView as? UITableView, let tableTagEnum = TableTag(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .BillAmount:
                self.updateBillAmountText()
            case .TipAmount:
                self.updateTipAmountText()
            }
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
        let count: Int?
        if let tableTagEnum = TableTag(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .BillAmount:
                count = self.billAmountsArray.count
            case .TipAmount:
                count = self.tipAmountsArray.count
            }
        } else {
            count = nil
        }
        return count !! 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: GratuitousTableViewCell?
        
        if let tableTagEnum = TableTag(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .BillAmount:
                cell = tableView.dequeueReusableCellWithIdentifier(self.billTableViewCellString) as? GratuitousTableViewCell
            case .TipAmount:
                cell = tableView.dequeueReusableCellWithIdentifier(self.tipTableViewCellString) as? GratuitousTableViewCell
            }
            
            cell?.textSizeAdjustment = self.lowerTextSizeAdjustment
            if cell?.currencyFormatter == nil {
                cell?.currencyFormatter = self.currencyFormatter
            }
            
            // Need to set the billamount after setting the currency formatter, or else there are bugs.
            switch tableTagEnum {
            case .BillAmount:
                cell?.billAmount = self.billAmountsArray[indexPath.row]
            case .TipAmount:
                cell?.billAmount = self.tipAmountsArray[indexPath.row]
            }
        } else {
            cell = nil
        }
        
        return cell !! UITableViewCell()
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
            self.upperTextSizeAdjustment = 0.76
        case .iPhone6:
            self.tipPercentageTextLabelTopConstraint.constant = -10.0
            self.totalAmountTextLabelBottomConstraint.constant = -10.0
            self.upperTextSizeAdjustment = 0.85
        case .iPhone6Plus:
            self.tipPercentageTextLabelTopConstraint.constant = -20.0
            self.totalAmountTextLabelBottomConstraint.constant = -10.0
            self.upperTextSizeAdjustment = 1.0
        case .iPad:
            self.tipPercentageTextLabelTopConstraint.constant = -25.0
            self.totalAmountTextLabelBottomConstraint.constant = -5.0
            self.upperTextSizeAdjustment = 1.3
        }
    }
    
    private func prepareTotalAmountTextLabel() {
        if let originalFont = GratuitousUIConstant.originalFontForTotalAmountTextLabel() {
            self.totalAmountTextLabel.font = originalFont
        }
        let font = self.totalAmountTextLabel.font.fontWithSize(self.totalAmountTextLabel.font.pointSize * self.upperTextSizeAdjustment)
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
        let font = self.tipPercentageTextLabel.font.fontWithSize(self.tipPercentageTextLabel.font.pointSize * self.upperTextSizeAdjustment)
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

