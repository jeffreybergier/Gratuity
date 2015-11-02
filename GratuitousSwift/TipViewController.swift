//
//  TipViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import Crashlytics

final class TipViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomAnimatedTransitionable, UIViewControllerPreviewingDelegate {
    
    @IBOutlet private weak var tipPercentageTextLabel: UILabel?
    @IBOutlet private weak var totalAmountTextLabel: UILabel?
    @IBOutlet private weak var billAmountTableView: UITableView?
    @IBOutlet private weak var tipAmountTableView: UITableView?
    @IBOutlet private weak var tipPercentageTextLabelTopConstraint: NSLayoutConstraint?
    @IBOutlet private weak var totalAmountTextLabelBottomConstraint: NSLayoutConstraint?
    @IBOutlet private weak var billAmountTableViewTitleTextLabel: UILabel?
    @IBOutlet private weak var billAmountTableViewTitleTextLabelView: UIView?
    @IBOutlet private weak var tipAmountTableViewTitleTextLabel: UILabel?
    @IBOutlet private weak var tipAmountTableViewTitleTextLabelView: UIView?
    @IBOutlet private weak var billAmountSelectedSurroundView: UIView?
    @IBOutlet private weak var billAmountLowerGradientView: GratuitousGradientView?
    @IBOutlet private weak var selectedTableViewCellOutlineViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var largeTextWidthLandscapeOnlyConstraint: NSLayoutConstraint?
    @IBOutlet private weak var labelContainerView: UIView?
    @IBOutlet private weak var tableContainerView: UIView?
    @IBOutlet private weak var bottomButtonsContainerView: UIView?
    @IBOutlet private weak var settingsButton: UIButton?
    @IBOutlet private weak var splitBillButton: GratuitousBorderedButton?
    
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
    
    private enum TableTagIdentifier: Int {
        case BillAmount = 0, TipAmount
    }
    
    private lazy var presentationRightTransitionerDelegate = GratuitousTransitioningDelegate(type: .Right, animate: true)
    private lazy var presentationBottomTransitionerDelegate = GratuitousTransitioningDelegate(type: .Bottom, animate: true)
    
    private var totalAmountTextLabelAttributes = [String : NSObject]()
    private var tipPercentageTextLabelAttributes = [String : NSObject]()
    private var viewDidAppearOnce = false
    private var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferencesSetLocally = newValue }
    }
    
    private let currencyFormatter = GratuitousNumberFormatter(style: .RespondsToLocaleChanges)
    private let tableViewCellClass = GratuitousTableViewCell.description().componentsSeparatedByString(".").last !! "GratuitousTableViewCell"
    private let billTableViewCellString: String = {
        let className = GratuitousTableViewCell.description().componentsSeparatedByString(".").last
        if let className = className {
            return className  + "Bill"
        }
        return className !! "GratuitousTableViewCellBill"
    }()
    private let tipTableViewCellString: String = {
        let className = GratuitousTableViewCell.description().componentsSeparatedByString(".").last
        if let className = className {
            return className + "Tip"
        }
        return className !! "GratuitousTableViewCellTip"
    }()
    
    private var upperTextSizeAdjustment: CGFloat = 0.0
    private var lowerTextSizeAdjustment: CGFloat = 0.0
    private var billAmountsArray = [Int]()
    private var tipAmountsArray = [Int]()
    
    //MARK: Handle View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.resetInterfaceIdleTimer()
        
        // configure notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: NSCurrentLocaleDidChangeNotification, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setInterfaceRefreshNeeded:", name: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote, object: .None)

        
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
        self.billAmountTableView?.delegate = self
        self.billAmountTableView?.dataSource = self
        self.billAmountTableView?.tag = TableTagIdentifier.BillAmount.rawValue
        self.billAmountTableView?.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.billAmountTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.billAmountTableView?.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.billAmountTableView?.showsVerticalScrollIndicator = false
        self.billAmountTableView?.registerNib(UINib(nibName: self.tableViewCellClass, bundle: nil), forCellReuseIdentifier: billTableViewCellString)
        
        self.tipAmountTableView?.delegate = self
        self.tipAmountTableView?.dataSource = self
        self.tipAmountTableView?.tag = TableTagIdentifier.TipAmount.rawValue
        self.tipAmountTableView?.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.tipAmountTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tipAmountTableView?.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.tipAmountTableView?.showsVerticalScrollIndicator = false
        self.tipAmountTableView?.registerNib(UINib(nibName: self.tableViewCellClass, bundle: nil), forCellReuseIdentifier: tipTableViewCellString)
        
        //configure color of view
        self.view.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.tipPercentageTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.totalAmountTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.tipAmountTableViewTitleTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
        self.billAmountTableViewTitleTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
        self.tipAmountTableViewTitleTextLabelView?.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        self.billAmountTableViewTitleTextLabelView?.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        
        //configure the text
        self.billAmountTableViewTitleTextLabel?.text = TipViewController.LocalizedString.BillAmountHeader
        self.tipAmountTableViewTitleTextLabel?.text = TipViewController.LocalizedString.SuggestTipHeader
        self.prepareSplitBillButton()
        
        //prepare the cell select surrounds
        self.prepareCellSelectSurroundView()
        
        //prepare lower gradient view so its upside down
        self.billAmountLowerGradientView?.isUpsideDown = true
        
        //prepare the primary view for the animation in
        self.labelContainerView?.alpha = 0
        self.tableContainerView?.alpha = 0
        self.bottomButtonsContainerView?.alpha = 0
        
        //check screensize and set text side adjustment
        self.checkForScreenSizeConstraintAdjustments()
        self.lowerTextSizeAdjustment = GratuitousUIConstant.correctCellTextSize().textSizeAdjustment()
        self.selectedTableViewCellOutlineViewHeightConstraint?.constant = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.largeTextWidthLandscapeOnlyConstraint?.constant = GratuitousUIConstant.largeTextLandscapeConstant()
        
        //prepare the settings button
        self.prepareSettingsButton()
        
        //was previously in viewWillAppear
        self.prepareTotalAmountTextLabel()
        self.prepareTipPercentageTextLabel()
        
        //register for 3d touch
        if #available(iOS 9.0, *) {
            if(traitCollection.forceTouchCapability == .Available) {
                self.registerForPreviewingWithDelegate(self, sourceView: self.view)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.viewDidAppearOnce == false {
            self.updateTableViewsFromDisk()
            UIView.animateWithDuration(GratuitousUIConstant.animationDuration() * 3.0,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0,
                options: UIViewAnimationOptions.AllowUserInteraction,
                animations: { () -> Void in
                    self.labelContainerView?.alpha = 1.0
                    self.tableContainerView?.alpha = 1.0
                    self.bottomButtonsContainerView?.alpha = 1.0
                }, completion: nil)
            
            // Launch the apple watch info screen if needed
            self.viewDidAppearOnce = true
        }
        
        Answers.logContentViewWithName(AnswersString.ViewDidAppear, contentType: .None, contentId: .None, customAttributes: .None)
    }

    private func updateTableViewsFromDisk() {
        let billAmount = self.applicationPreferences.billIndexPathRow + PrivateConstants.ExtraCells - 1
        
        self.billAmountTableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: billAmount, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        
        let tipAmount: Int
        if self.applicationPreferences.tipIndexPathRow > 0 {
            tipAmount = self.applicationPreferences.tipIndexPathRow + PrivateConstants.ExtraCells - 1
            self.tipAmountTableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: tipAmount, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        } else {
            //
            // This big block of code tries to calculate the actual tip and adjust the UI
            // This is needed because unless a custom tip is set, the tip on disk == 0
            //
            if let billAmountTableView = self.billAmountTableView,
                let tipAmountTableView = self.tipAmountTableView,
                let billIndexPath = self.indexPathInCenterOfTable(billAmountTableView),
                let tipIndexPath = self.indexPathInCenterOfTable(tipAmountTableView),
                let billCell = billAmountTableView.cellForRowAtIndexPath(billIndexPath) as? GratuitousTableViewCell,
                let tipCell = tipAmountTableView.cellForRowAtIndexPath(tipIndexPath) as? GratuitousTableViewCell {
                    let actualBillCellAmount = billCell.billAmount
                    let tipDifference = billAmount - actualBillCellAmount
                    let tipAmount = tipCell.billAmount
                    let adjustedTipIndexPathRow = tipAmount + tipDifference
                    tipAmountTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: adjustedTipIndexPathRow, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
                    self.updateLargeTextLabels(billAmount: actualBillCellAmount, tipAmount: tipAmount)
            }
        }
    }
    
    private func prepareCellSelectSurroundView() {
        self.billAmountSelectedSurroundView?.backgroundColor = UIColor.clearColor()
        self.billAmountSelectedSurroundView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.billAmountSelectedSurroundView?.layer.cornerRadius = 0.0
        self.billAmountSelectedSurroundView?.layer.borderColor = GratuitousUIConstant.lightBackgroundColor().CGColor
        self.billAmountSelectedSurroundView?.backgroundColor = GratuitousUIConstant.lightBackgroundColor().colorWithAlphaComponent(0.15)
    }
    
    private func prepareSettingsButton() {
        self.settingsButton?.setImage(nil, forState: UIControlState.Normal)
        self.settingsButton?.titleLabel?.font = UIFont.preferredFontForTextStyle(self.splitBillButton?.titleStyle.description !! UIFontStyle.Body.description)
        self.settingsButton?.setTitle(TipViewController.LocalizedString.SettingsButton, forState: UIControlState.Normal)
        self.prepareSplitBillButton()
        self.settingsButton?.sizeToFit()
        if let path = NSBundle.mainBundle().pathForResource("settingsIcon", ofType:"pdf"),
            let settingsButton = self.settingsButton {
                let image = ImageFromPDFFileWithHeight(path, settingsButton.frame.size.height).imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                settingsButton.setTitle("", forState: UIControlState.Normal)
                settingsButton.setImage(image, forState: UIControlState.Normal)
                settingsButton.sizeToFit()
        }
    }
    
    //MARK: Handle User Input
    
    @IBAction private func didTapBillAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        self.billAmountTableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0 + PrivateConstants.ExtraCells, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.scrollViewDidStopMovingForWhateverReason(self.billAmountTableView!)
        }
    }
    
    @IBAction private func didTapTipAmountTableViewScrollToTop(sender: UITapGestureRecognizer) {
        self.tipAmountTableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0 + PrivateConstants.ExtraCells, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.scrollViewDidStopMovingForWhateverReason(self.tipAmountTableView!)
        }
    }
    
    @IBAction private func unwindToViewController(segue: UIStoryboardSegue) {

    }
    
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .NotApplicable
    }
    
    enum StoryboardSegues: String {
        case Settings
        case WatchInfo
        case SplitBill
        case PurchaseSplitBill
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        guard let segue = StoryboardSegues(rawValue: identifier) else { return true }
        
        switch segue {
        case .SplitBill:
            if self.applicationPreferences.splitBillPurchased == true {
                // if the preferences say its true trust them.
                // this is for deferred purchases grace period
                return true
            } else {
                // if not true, check the receipt and try again
                let purchaseManager = GratuitousPurchaseManager()
                self.applicationPreferences.splitBillPurchased = purchaseManager.verifySplitBillPurchaseTransaction()
                if self.applicationPreferences.splitBillPurchased == true {
                    return true
                } else {
                    self.performSegueWithIdentifier(StoryboardSegues.PurchaseSplitBill.rawValue, sender: self)
                    return false
                }
            }
        default:
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let animatableDestinationViewController = segue.destinationViewController as? CustomAnimatedTransitionable else { return }
        
        switch animatableDestinationViewController.customTransitionType {
        case .Right:
            segue.destinationViewController.transitioningDelegate = self.presentationRightTransitionerDelegate
            segue.destinationViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        case .Bottom:
            segue.destinationViewController.transitioningDelegate = self.presentationBottomTransitionerDelegate
            segue.destinationViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        case .NotApplicable:
            break
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
            options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.BeginFromCurrentState],
            animations: {
                self.labelContainerView?.transform = transform
                self.labelContainerView?.alpha = alpha
            },
            completion: { finished in
                //do nothing
        })
    }
    
    //MARK: Handle 3D Touch
    
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let purchased: Bool
        if self.applicationPreferences.splitBillPurchased == true {
            // if the preferences say its true trust them.
            // this is for deferred purchases grace period
            purchased = true
        } else {
            // if not true, check the receipt and try again
            let purchaseManager = GratuitousPurchaseManager()
            self.applicationPreferences.splitBillPurchased = purchaseManager.verifySplitBillPurchaseTransaction()
            purchased = self.applicationPreferences.splitBillPurchased
        }
        
        if purchased == true {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SplitBillViewController") as? SmallModalViewController {
                if let buttonFrame = self.splitBillButton?.frame {
                    previewingContext.sourceRect = self.view.convertRect(buttonFrame, fromView: self.splitBillButton?.superview)
                }
                vc.setPeekModeEnabled()
                return vc
            }
        }

        return .None
    }
    
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.performSegueWithIdentifier(StoryboardSegues.SplitBill.rawValue, sender: self)
    }
    
    //MARK: Handle Writing to Disk
    
    private func writeToDiskBillTableIndexPath(indexPath: NSIndexPath) {
        self.applicationPreferences.billIndexPathRow = indexPath.row - PrivateConstants.ExtraCells + 1
    }
    
    private func writeToDiskTipTableIndexPath(indexPath: NSIndexPath, WithAutoAdjustment autoAdjustment: Bool) {
        // Auto adjustment lets me know when we are saving an actual value of tip vs just setting the tipamount to 0 or 1 for logic reasons.
        if autoAdjustment == true {
            self.applicationPreferences.tipIndexPathRow = indexPath.row - PrivateConstants.ExtraCells + 1
        } else {
            self.applicationPreferences.tipIndexPathRow = indexPath.row
        }
    }
    
    //MARK: Handle Updating the Big Labels
    
    @objc private func currencySignChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currencyFormatter.locale = NSLocale.currentLocale()
            self.refreshInterface()
        }
    }
    
    private func updateLargeTextLabels(billAmount billAmount: Int, tipAmount: Int) {
        self.resetInterfaceIdleTimer()
        if billAmount > 0 { //this protects from divide by 0 crashes
            let currencySign = self.applicationPreferences.overrideCurrencySymbol
            let totalAmount = billAmount + tipAmount
            let tipPercentage = Int(round(Double(tipAmount) / Double(billAmount) * 100))
            
            let currencyFormattedString = self.currencyFormatter.currencyFormattedStringWithCurrencySign(currencySign, amount: totalAmount)
            let totalAmountAttributedString = NSAttributedString(string: currencyFormattedString, attributes: self.totalAmountTextLabelAttributes)
            let tipPercentageAttributedString = NSAttributedString(string: "\(tipPercentage)%", attributes: self.tipPercentageTextLabelAttributes)
            
            self.totalAmountTextLabel?.attributedText = totalAmountAttributedString
            self.tipPercentageTextLabel?.attributedText = tipPercentageAttributedString
        }
    }
    
    private var interfaceIdleTimer: NSTimer?
    private func resetInterfaceIdleTimer() {
        self.interfaceIdleTimer?.invalidate()
        self.interfaceIdleTimer = nil
        self.interfaceIdleTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "interfaceIdleTimerFired:", userInfo: nil, repeats: true)
    }
    
    @objc private func interfaceIdleTimerFired(timer: NSTimer?) {
        if self.interfaceRefreshNeeded == true {
            let billIndex = self.applicationPreferences.billIndexPathRow
            let tipIndex = self.applicationPreferences.tipIndexPathRow
            self.billAmountTableView?.selectRowAtIndexPath(NSIndexPath(forRow: billIndex + 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            if tipIndex > 0 {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.tipAmountTableView?.selectRowAtIndexPath(NSIndexPath(forRow: tipIndex + 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                }
            }
            self.refreshInterface()
        }
    }
    
    private var interfaceRefreshNeeded = false
    @objc private func setInterfaceRefreshNeeded(notification: NSNotification? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            self.interfaceRefreshNeeded = true
        }
    }
    
    func refreshInterface() {
        self.interfaceRefreshNeeded = false
        if let billAmountTableView = self.billAmountTableView,
            let tipAmountTableView = self.tipAmountTableView,
            let billIndexPath = self.indexPathInCenterOfTable(billAmountTableView),
            let billCell = billAmountTableView.cellForRowAtIndexPath(billIndexPath) as? GratuitousTableViewCell {
                let suggestedTipPercentage = self.applicationPreferences.suggestedTipPercentage
                let billAmount = billCell.billAmount
                if billAmount > 0 {
                    let tipAmount: Int
                    let tipUserDefaults = self.applicationPreferences.tipIndexPathRow
                    if let tipIndexPath = self.indexPathInCenterOfTable(tipAmountTableView),
                        let tipCell = tipAmountTableView.cellForRowAtIndexPath(tipIndexPath) as? GratuitousTableViewCell {
                            if tipUserDefaults != 0 {
                                tipAmount = tipCell.billAmount
                            } else {
                                tipAmount = Int(round((Double(billAmount) * suggestedTipPercentage)))
                            }
                            self.updateLargeTextLabels(billAmount: billAmount, tipAmount: tipAmount)
                    }
                }
        }
        if let cells = self.billAmountTableView?.visibleCells {
            cells.forEach() { genericCell in
                if let cell = genericCell as? GratuitousTableViewCell {
                    cell.setInterfaceRefreshNeeded()
                }
            }
        }
        if let cells = self.tipAmountTableView?.visibleCells {
            cells.forEach() { genericCell in
                if let cell = genericCell as? GratuitousTableViewCell {
                    cell.setInterfaceRefreshNeeded()
                }
            }
        }
    }
    
    private func prepareSplitBillButton() {
        self.splitBillButton?.titleStyle = UIFontStyle.Body
        self.splitBillButton?.setTitle(TipViewController.LocalizedString.SpltBillButton, forState: .Normal)
        self.splitBillButton?.sizeToFit()
    }
    
    //MARK: Handle Table View User Input
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .BillAmount:
                self.writeToDiskBillTableIndexPath(indexPath)
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            case .TipAmount:
                self.writeToDiskTipTableIndexPath(indexPath, WithAutoAdjustment: true)
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
            self.bigTextLabelsShouldPresent(false)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.scrollViewDidStopMovingForWhateverReason(tableView)
            }
        }
    }
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            self.scrollViewDidStopMovingForWhateverReason(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollViewDidEndScrollingAnimation(scrollView)
        self.scrollViewDidStopMovingForWhateverReason(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.bigTextLabelsShouldPresent(true)
        if let tableView = scrollView as? UITableView,
            let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag),
            let indexPath = self.indexPathInCenterOfTable(tableView) {
                switch tableTagEnum {
                case .BillAmount:
                    self.writeToDiskBillTableIndexPath(indexPath)
                case .TipAmount:
                    self.writeToDiskTipTableIndexPath(indexPath, WithAutoAdjustment: true)
                }
        }
    }
    
    private func scrollViewDidStopMovingForWhateverReason(scrollView: UIScrollView) {
        self.bigTextLabelsShouldPresent(true)
        if let tableView = scrollView as? UITableView,
            let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag),
            let indexPath = self.indexPathInCenterOfTable(tableView) {
                switch tableTagEnum {
                case .BillAmount:
                    self.writeToDiskBillTableIndexPath(indexPath)
                    tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                case .TipAmount:
                    self.writeToDiskTipTableIndexPath(indexPath, WithAutoAdjustment: true)
                    tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
                }
        }
        self.postNewCalculationToAnswers()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.bigTextLabelsShouldPresent(false)
        if let tag = TableTagIdentifier(rawValue: scrollView.tag) {
            // these defaults writes keep track of whether a custom tip amount is set
            // without using an instance variable
            switch tag {
            case .BillAmount:
                self.writeToDiskTipTableIndexPath(NSIndexPath(forRow: 0, inSection: 0), WithAutoAdjustment: false)
            case .TipAmount:
                self.writeToDiskTipTableIndexPath(NSIndexPath(forRow: 1, inSection: 0), WithAutoAdjustment: false)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let tableTagEnum = TableTagIdentifier(rawValue: scrollView.tag),
            let billAmountTableView = self.billAmountTableView,
            let tipAmountTableView = self.tipAmountTableView,
            let billAmountIndexPath = self.indexPathInCenterOfTable(billAmountTableView),
            let tipAmountIndexPath = self.indexPathInCenterOfTable(tipAmountTableView),
            let billCell = billAmountTableView.cellForRowAtIndexPath(billAmountIndexPath) as? GratuitousTableViewCell,
            let tipCell = tipAmountTableView.cellForRowAtIndexPath(tipAmountIndexPath) as? GratuitousTableViewCell {
                let billAmount = billCell.billAmount
                let tipAmount = Int(round((Double(billAmount) * self.applicationPreferences.suggestedTipPercentage)))
                switch tableTagEnum {
                case .BillAmount:
                    if self.applicationPreferences.tipIndexPathRow == 0 {
                        let cellOffset = billAmountIndexPath.row - billAmount
                        let adjustedTipIndexPathRow = tipAmount + cellOffset
                        if billAmount > 0 { // this stops a crash when the user scrolls past the end of the billtable
                            tipAmountTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: adjustedTipIndexPathRow, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
                        }
                    }
                    self.updateLargeTextLabels(billAmount: billAmount, tipAmount: tipAmount)
                case .TipAmount:
                    let tipAmount = tipCell.billAmount
                    self.updateLargeTextLabels(billAmount: billAmount, tipAmount: tipAmount)
                }
        }
    }
    
    private func postNewCalculationToAnswers() {
        let c = DefaultsCalculations(preferences: self.applicationPreferences)
        
        var answersAttributes = [
            "BillAmount" : NSNumber(integer: c.billAmount),
            "TipAmount" : NSNumber(integer: c.tipAmount),
            "TipPercentage" : NSNumber(integer: c.tipPercentage),
            "TotalAmount" : NSNumber(integer: c.totalAmount),
            "SystemLocale" : self.currencyFormatter.locale.localeIdentifier
        ]
        
        answersAttributes["LocationZipCode"] = self.applicationPreferences.lastLocation?.zipCode
        answersAttributes["LocationCity"] = self.applicationPreferences.lastLocation?.city
        answersAttributes["LocationRegion"] = self.applicationPreferences.lastLocation?.region
        answersAttributes["LocationCountry"] = self.applicationPreferences.lastLocation?.country
        answersAttributes["LocationCountryCode"] = self.applicationPreferences.lastLocation?.countryCode
        
        Answers.logCustomEventWithName(AnswersString.NewTipCalculated, customAttributes: answersAttributes)
    }
    
    //MARK: Handle Table View Delegate DataSourceStuff
    
    private func indexPathInCenterOfTable(tableView: UITableView) -> NSIndexPath? {
        let indexPath: NSIndexPath?
        
        var point = tableView.frame.origin
        point.x += tableView.frame.size.width / 2
        point.y += tableView.frame.size.height / 2
        point = tableView.convertPoint(point, fromView: tableView.superview)
        if let optionalIndexPath = tableView.indexPathForRowAtPoint(point) {
            indexPath = optionalIndexPath
        } else {
            indexPath = nil
        }
        
        return indexPath !! NSIndexPath(forRow: 0, inSection: 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int?
        if let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag) {
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
        
        if let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .BillAmount:
                cell = tableView.dequeueReusableCellWithIdentifier(self.billTableViewCellString) as? GratuitousTableViewCell
            case .TipAmount:
                cell = tableView.dequeueReusableCellWithIdentifier(self.tipTableViewCellString) as? GratuitousTableViewCell
            }
            
            cell?.textSizeAdjustment = self.lowerTextSizeAdjustment
            
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
        let rowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        
        return rowHeight
    }
    
    //MARK: View Controller Preferences
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    //MARK: Handle Text Size Adjustment and Label Attributed Strings
    
    @objc private func systemTextSizeDidChange(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            //adjust text size
            self.lowerTextSizeAdjustment = GratuitousUIConstant.correctCellTextSize().textSizeAdjustment()
            self.selectedTableViewCellOutlineViewHeightConstraint?.constant = GratuitousUIConstant.correctCellTextSize().rowHeight()
            self.largeTextWidthLandscapeOnlyConstraint?.constant = GratuitousUIConstant.largeTextLandscapeConstant()
            
            //estimated row height
            self.billAmountTableView?.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
            self.tipAmountTableView?.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
            
            //update the view
            self.prepareSettingsButton()
            self.prepareSplitBillButton()
            self.billAmountTableView?.reloadData()
            self.tipAmountTableView?.reloadData()
            
            //reload the tables
            self.updateTableViewsFromDisk()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        //this line stops a bug with the transforms on rotation
        self.view.transform = CGAffineTransformIdentity
        
        coordinator.animateAlongsideTransition(nil, completion: { finished in
            self.updateTableViewsFromDisk()
        })
    }
    
    private func checkForScreenSizeConstraintAdjustments() {
        switch GratuitousUIConstant.actualScreenSizeBasedOnWidth() {
        case .iPhone4or5:
            self.tipPercentageTextLabelTopConstraint?.constant = -15.0
            self.totalAmountTextLabelBottomConstraint?.constant = -12.0
            self.upperTextSizeAdjustment = 0.76
        case .iPhone6:
            self.tipPercentageTextLabelTopConstraint?.constant = -10.0
            self.totalAmountTextLabelBottomConstraint?.constant = -10.0
            self.upperTextSizeAdjustment = 0.85
        case .iPhone6Plus:
            self.tipPercentageTextLabelTopConstraint?.constant = -20.0
            self.totalAmountTextLabelBottomConstraint?.constant = -10.0
            self.upperTextSizeAdjustment = 1.0
        case .iPad:
            self.tipPercentageTextLabelTopConstraint?.constant = -25.0
            self.totalAmountTextLabelBottomConstraint?.constant = -5.0
            self.upperTextSizeAdjustment = 1.3
        }
    }
    
    private func prepareTotalAmountTextLabel() {
        if let totalAmountTextLabel = self.totalAmountTextLabel {
            if let originalFont = GratuitousUIConstant.originalFontForTotalAmountTextLabel() {
                totalAmountTextLabel.font = originalFont
            }
            let font = totalAmountTextLabel.font.fontWithSize(totalAmountTextLabel.font.pointSize * self.upperTextSizeAdjustment)
            let textColor = totalAmountTextLabel.textColor
            let text = totalAmountTextLabel.text
            let shadow = NSShadow()
            shadow.shadowColor = GratuitousUIConstant.textShadowColor()
            shadow.shadowBlurRadius = 2.0
            shadow.shadowOffset = CGSizeMake(2.0, 2.0)
            let attributes: [String : NSObject] = [
                NSForegroundColorAttributeName : textColor,
                NSFontAttributeName : font,
                //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
                NSShadowAttributeName : shadow
            ]
            self.totalAmountTextLabelAttributes = attributes
            let attributedString: NSAttributedString
            if let text = text {
                attributedString = NSAttributedString(string: text, attributes: self.totalAmountTextLabelAttributes)
            } else {
                attributedString = NSAttributedString(string: "", attributes: self.totalAmountTextLabelAttributes)
            }
            totalAmountTextLabel.attributedText = attributedString
        }
    }
    
    private func prepareTipPercentageTextLabel() {
        if let tipPercentageTextLabel = self.tipPercentageTextLabel {
            if let originalFont = GratuitousUIConstant.originalFontForTipPercentageTextLabel() {
                tipPercentageTextLabel.font = originalFont
            }
            let font = tipPercentageTextLabel.font.fontWithSize(tipPercentageTextLabel.font.pointSize * self.upperTextSizeAdjustment)
            let textColor = tipPercentageTextLabel.textColor
            let text = tipPercentageTextLabel.text !! ""
            let shadow = NSShadow()
            shadow.shadowColor = GratuitousUIConstant.textShadowColor()
            shadow.shadowBlurRadius = 2.0
            shadow.shadowOffset = CGSizeMake(2.0, 2.0)
            let attributes: [String : NSObject] = [
                NSForegroundColorAttributeName : textColor,
                NSFontAttributeName : font,
                //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
                NSShadowAttributeName : shadow
            ]
            self.tipPercentageTextLabelAttributes = attributes
            let attributedString = NSAttributedString(string: text, attributes: self.tipPercentageTextLabelAttributes)
            tipPercentageTextLabel.attributedText = attributedString
        }
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

