//
//  TipViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class TipViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomAnimatedTransitionable, UIViewControllerPreviewingDelegate {
    
    @IBOutlet fileprivate weak var tipPercentageTextLabel: UILabel?
    @IBOutlet fileprivate weak var totalAmountTextLabel: UILabel?
    @IBOutlet fileprivate weak var billAmountTableView: UITableView?
    @IBOutlet fileprivate weak var tipAmountTableView: UITableView?
    @IBOutlet fileprivate weak var tipPercentageTextLabelTopConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var totalAmountTextLabelBottomConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var billAmountTableViewTitleTextLabel: UILabel?
    @IBOutlet fileprivate weak var billAmountTableViewTitleTextLabelView: UIView?
    @IBOutlet fileprivate weak var tipAmountTableViewTitleTextLabel: UILabel?
    @IBOutlet fileprivate weak var tipAmountTableViewTitleTextLabelView: UIView?
    @IBOutlet fileprivate weak var billAmountSelectedSurroundView: UIView?
    @IBOutlet fileprivate weak var billAmountLowerGradientView: GratuitousGradientView?
    @IBOutlet fileprivate weak var selectedTableViewCellOutlineViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var largeTextWidthLandscapeOnlyConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var labelContainerView: UIView?
    @IBOutlet fileprivate weak var tableContainerView: UIView?
    @IBOutlet fileprivate weak var bottomButtonsContainerView: UIView?
    @IBOutlet fileprivate weak var settingsButton: UIButton?
    @IBOutlet fileprivate weak var splitBillButton: GratuitousBorderedButton?
    
    fileprivate struct PrivateConstants {
        static let MaxBillAmount = 2000
        static let MaxTipAmount = 1000
        static let ExtraCells: Int = {
            if UIScreen.main.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                return 3
            } else {
                return 2
            }
        }()
    }
    
    fileprivate enum TableTagIdentifier: Int {
        case billAmount = 0, tipAmount
    }
    
    fileprivate lazy var presentationRightTransitionerDelegate = GratuitousTransitioningDelegate(type: .right, animate: true)
    fileprivate lazy var presentationBottomTransitionerDelegate = GratuitousTransitioningDelegate(type: .bottom, animate: true)
    
    fileprivate var totalAmountTextLabelAttributes = [NSAttributedStringKey : Any]()
    fileprivate var tipPercentageTextLabelAttributes = [NSAttributedStringKey : Any]()
    fileprivate var viewDidAppearOnce = false
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.shared.delegate as! GratuitousAppDelegate).preferencesSetLocally = newValue }
    }
    
    fileprivate let currencyFormatter = GratuitousNumberFormatter(style: .respondsToLocaleChanges)
    fileprivate let tableViewCellClass = GratuitousTableViewCell.description().components(separatedBy: ".").last !! "GratuitousTableViewCell"
    fileprivate let billTableViewCellString: String = {
        let className = GratuitousTableViewCell.description().components(separatedBy: ".").last
        if let className = className {
            return className  + "Bill"
        }
        return className !! "GratuitousTableViewCellBill"
    }()
    fileprivate let tipTableViewCellString: String = {
        let className = GratuitousTableViewCell.description().components(separatedBy: ".").last
        if let className = className {
            return className + "Tip"
        }
        return className !! "GratuitousTableViewCellTip"
    }()
    
    fileprivate var upperTextSizeAdjustment: CGFloat = 0.0
    fileprivate var lowerTextSizeAdjustment: CGFloat = 0.0
    fileprivate var billAmountsArray = [Int]()
    fileprivate var tipAmountsArray = [Int]()
    
    //MARK: Handle View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.resetInterfaceIdleTimer()
        
        // configure notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.systemTextSizeDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setInterfaceRefreshNeeded(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote), object: .none)

        
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
        self.billAmountTableView?.tag = TableTagIdentifier.billAmount.rawValue
        self.billAmountTableView?.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.billAmountTableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        self.billAmountTableView?.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.billAmountTableView?.showsVerticalScrollIndicator = false
        self.billAmountTableView?.register(UINib(nibName: self.tableViewCellClass, bundle: nil), forCellReuseIdentifier: billTableViewCellString)
        
        self.tipAmountTableView?.delegate = self
        self.tipAmountTableView?.dataSource = self
        self.tipAmountTableView?.tag = TableTagIdentifier.tipAmount.rawValue
        self.tipAmountTableView?.estimatedRowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        self.tipAmountTableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tipAmountTableView?.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.tipAmountTableView?.showsVerticalScrollIndicator = false
        self.tipAmountTableView?.register(UINib(nibName: self.tableViewCellClass, bundle: nil), forCellReuseIdentifier: tipTableViewCellString)
        
        //configure color of view
        self.view.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.tipPercentageTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.totalAmountTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.tipAmountTableViewTitleTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
        self.billAmountTableViewTitleTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
        self.tipAmountTableViewTitleTextLabelView?.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        self.billAmountTableViewTitleTextLabelView?.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
        self.billAmountTableViewTitleTextLabelView?.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.tipAmountTableViewTitleTextLabelView?.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        
        //configure the text
        self.billAmountTableViewTitleTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        self.tipAmountTableViewTitleTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
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
            if(traitCollection.forceTouchCapability == .available) {
                self.registerForPreviewing(with: self, sourceView: self.view)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.viewDidAppearOnce == false {
            self.updateTableViewsFromDisk()
            UIView.animate(withDuration: GratuitousUIConstant.animationDuration() * 3.0,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0,
                options: UIViewAnimationOptions.allowUserInteraction,
                animations: { () -> Void in
                    self.labelContainerView?.alpha = 1.0
                    self.tableContainerView?.alpha = 1.0
                    self.bottomButtonsContainerView?.alpha = 1.0
                }, completion: nil)
            
            // Launch the apple watch info screen if needed
            self.viewDidAppearOnce = true
        }
    }

    fileprivate func updateTableViewsFromDisk() {
        let billAmount = self.applicationPreferences.billIndexPathRow + PrivateConstants.ExtraCells - 1
        
        self.billAmountTableView?.scrollToRow(at: IndexPath(row: billAmount, section: 0), at: UITableViewScrollPosition.middle, animated: false)
        
        let tipAmount: Int
        if self.applicationPreferences.tipIndexPathRow > 0 {
            tipAmount = self.applicationPreferences.tipIndexPathRow + PrivateConstants.ExtraCells - 1
            self.tipAmountTableView?.scrollToRow(at: IndexPath(row: tipAmount, section: 0), at: UITableViewScrollPosition.middle, animated: false)
        } else {
            //
            // This big block of code tries to calculate the actual tip and adjust the UI
            // This is needed because unless a custom tip is set, the tip on disk == 0
            //
            if let billAmountTableView = self.billAmountTableView,
                let tipAmountTableView = self.tipAmountTableView,
                let billIndexPath = self.indexPathInCenterOfTable(billAmountTableView),
                let tipIndexPath = self.indexPathInCenterOfTable(tipAmountTableView),
                let billCell = billAmountTableView.cellForRow(at: billIndexPath) as? GratuitousTableViewCell,
                let tipCell = tipAmountTableView.cellForRow(at: tipIndexPath) as? GratuitousTableViewCell {
                    let actualBillCellAmount = billCell.billAmount
                    let tipDifference = billAmount - actualBillCellAmount
                    let tipAmount = tipCell.billAmount
                    let adjustedTipIndexPathRow = tipAmount + tipDifference
                    tipAmountTableView.scrollToRow(at: IndexPath(row: adjustedTipIndexPathRow, section: 0), at: UITableViewScrollPosition.middle, animated: false)
                    self.updateLargeTextLabels(billAmount: actualBillCellAmount, tipAmount: tipAmount)
            }
        }
    }
    
    fileprivate func prepareCellSelectSurroundView() {
        self.billAmountSelectedSurroundView?.backgroundColor = UIColor.clear
        self.billAmountSelectedSurroundView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.billAmountSelectedSurroundView?.layer.cornerRadius = 0.0
        self.billAmountSelectedSurroundView?.layer.borderColor = GratuitousUIConstant.lightBackgroundColor().cgColor
        self.billAmountSelectedSurroundView?.backgroundColor = GratuitousUIConstant.lightBackgroundColor().withAlphaComponent(0.15)
    }
    
    fileprivate func prepareSettingsButton() {
        self.settingsButton?.setImage(nil, for: UIControlState())
        self.settingsButton?.titleLabel?.font = UIFont.preferredFont(forTextStyle: self.splitBillButton?.titleStyle !! .body)
        self.settingsButton?.setTitle(TipViewController.LocalizedString.SettingsButton, for: UIControlState())
        self.prepareSplitBillButton()
        self.settingsButton?.sizeToFit()
        if let path = Bundle.main.path(forResource: "settingsIcon", ofType:"pdf"),
            let settingsButton = self.settingsButton {
            let image = ImageFromPDFFileWithHeight(path, settingsButton.frame.size.height).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            settingsButton.setTitle("", for: UIControlState())
            settingsButton.setImage(image, for: .normal)
            settingsButton.sizeToFit()
        }
    }
    
    //MARK: Handle User Input
    
    @IBAction fileprivate func didTapBillAmountTableViewScrollToTop(_ sender: UITapGestureRecognizer) {
        self.billAmountTableView?.scrollToRow(at: IndexPath(row: 0 + PrivateConstants.ExtraCells, section: 0), at: UITableViewScrollPosition.middle, animated: true)
        let delayTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.scrollViewDidStopMovingForWhateverReason(self.billAmountTableView!)
        }
    }
    
    @IBAction fileprivate func didTapTipAmountTableViewScrollToTop(_ sender: UITapGestureRecognizer) {
        self.tipAmountTableView?.scrollToRow(at: IndexPath(row: 0 + PrivateConstants.ExtraCells, section: 0), at: UITableViewScrollPosition.middle, animated: true)
        let delayTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.scrollViewDidStopMovingForWhateverReason(self.tipAmountTableView!)
        }
    }
    
    @IBAction fileprivate func unwindToViewController(_ segue: UIStoryboardSegue) {

    }
    
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .notApplicable
    }
    
    enum StoryboardSegues: String {
        case Settings
        case WatchInfo
        case SplitBill
        case PurchaseSplitBill
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
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
                    self.performSegue(withIdentifier: StoryboardSegues.PurchaseSplitBill.rawValue, sender: self)
                    return false
                }
            }
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let animatableDestinationViewController = segue.destination as? CustomAnimatedTransitionable else { return }
        
        switch animatableDestinationViewController.customTransitionType {
        case .right:
            segue.destination.transitioningDelegate = self.presentationRightTransitionerDelegate
            segue.destination.modalPresentationStyle = UIModalPresentationStyle.custom
        case .bottom:
            segue.destination.transitioningDelegate = self.presentationBottomTransitionerDelegate
            segue.destination.modalPresentationStyle = UIModalPresentationStyle.custom
        case .notApplicable:
            break
        }
    }
    
    fileprivate func bigTextLabelsShouldPresent(_ presenting: Bool) {
        var transform = presenting ? CGAffineTransform.identity : CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        var alpha: CGFloat = presenting ? 1.0 : 0.5
        if self.presentedViewController != nil {
            //if the view controller is presenting something, I want these values to always be big
            transform = CGAffineTransform.identity
            alpha = 1.0
        }
        
        UIView.animate(withDuration: GratuitousUIConstant.animationDuration(),
            delay: presenting ? 0.05 : 0.05,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 1.9,
            options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState],
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
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
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
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplitBillViewController") as? SmallModalViewController {
                if let buttonFrame = self.splitBillButton?.frame {
                    previewingContext.sourceRect = self.view.convert(buttonFrame, from: self.splitBillButton?.superview)
                }
                vc.setPeekModeEnabled()
                return vc
            }
        }

        return .none
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        viewControllerToCommit.transitioningDelegate = self.presentationBottomTransitionerDelegate
        viewControllerToCommit.modalPresentationStyle = UIModalPresentationStyle.custom
        (viewControllerToCommit as? SmallModalViewController)?.setPopModeEnabled()
        self.present(viewControllerToCommit, animated: true, completion: .none)
    }
    
    //MARK: Handle Writing to Disk
    
    fileprivate func writeToDiskBillTableIndexPath(_ indexPath: IndexPath) {
        self.applicationPreferences.billIndexPathRow = indexPath.row - PrivateConstants.ExtraCells + 1
    }
    
    fileprivate func writeToDiskTipTableIndexPath(_ indexPath: IndexPath, WithAutoAdjustment autoAdjustment: Bool) {
        // Auto adjustment lets me know when we are saving an actual value of tip vs just setting the tipamount to 0 or 1 for logic reasons.
        if autoAdjustment == true {
            self.applicationPreferences.tipIndexPathRow = indexPath.row - PrivateConstants.ExtraCells + 1
        } else {
            self.applicationPreferences.tipIndexPathRow = indexPath.row
        }
    }
    
    //MARK: Handle Updating the Big Labels
    
    @objc fileprivate func currencySignChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.currencyFormatter.locale = Locale.current
            self.refreshInterface()
        }
    }
    
    fileprivate func updateLargeTextLabels(billAmount: Int, tipAmount: Int) {
        self.resetInterfaceIdleTimer()
        if billAmount > 0 { //this protects from divide by 0 crashes
            let currencySign = self.applicationPreferences.overrideCurrencySymbol
            let totalAmount = billAmount + tipAmount
            let tipPercentage = Int(round((Double(tipAmount) /? Double(billAmount)) * 100))
            
            let currencyFormattedString = self.currencyFormatter.currencyFormattedStringWithCurrencySign(currencySign, amount: totalAmount)
            let totalAmountAttributedString = NSAttributedString(string: currencyFormattedString, attributes: self.totalAmountTextLabelAttributes)
            let tipPercentageAttributedString = NSAttributedString(string: "\(tipPercentage)%", attributes: self.tipPercentageTextLabelAttributes)
            
            self.totalAmountTextLabel?.attributedText = totalAmountAttributedString
            self.tipPercentageTextLabel?.attributedText = tipPercentageAttributedString
        }
    }
    
    fileprivate var interfaceIdleTimer: Timer?
    fileprivate func resetInterfaceIdleTimer() {
        self.interfaceIdleTimer?.invalidate()
        self.interfaceIdleTimer = nil
        self.interfaceIdleTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.interfaceIdleTimerFired(_:)), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func interfaceIdleTimerFired(_ timer: Timer?) {
        if self.interfaceRefreshNeeded == true {
            let billIndex = self.applicationPreferences.billIndexPathRow
            let tipIndex = self.applicationPreferences.tipIndexPathRow
            self.billAmountTableView?.selectRow(at: IndexPath(row: billIndex + 1, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
            if tipIndex > 0 {
                let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.tipAmountTableView?.selectRow(at: IndexPath(row: tipIndex + 1, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
                }
            }
            self.refreshInterface()
        }
    }
    
    fileprivate var interfaceRefreshNeeded = false
    @objc fileprivate func setInterfaceRefreshNeeded(_ notification: Notification? = nil) {
        DispatchQueue.main.async {
            self.interfaceRefreshNeeded = true
        }
    }
    
    func refreshInterface() {
        self.interfaceRefreshNeeded = false
        if let billAmountTableView = self.billAmountTableView,
            let tipAmountTableView = self.tipAmountTableView,
            let billIndexPath = self.indexPathInCenterOfTable(billAmountTableView),
            let billCell = billAmountTableView.cellForRow(at: billIndexPath) as? GratuitousTableViewCell {
                let suggestedTipPercentage = self.applicationPreferences.suggestedTipPercentage
                let billAmount = billCell.billAmount
                if billAmount > 0 {
                    let tipAmount: Int
                    let tipUserDefaults = self.applicationPreferences.tipIndexPathRow
                    if let tipIndexPath = self.indexPathInCenterOfTable(tipAmountTableView),
                        let tipCell = tipAmountTableView.cellForRow(at: tipIndexPath) as? GratuitousTableViewCell {
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
    
    fileprivate func prepareSplitBillButton() {
        self.splitBillButton?.titleStyle = .body
        self.splitBillButton?.setTitle(TipViewController.LocalizedString.SpltBillButton, for: UIControlState())
        self.splitBillButton?.sizeToFit()
    }
    
    //MARK: Handle Table View User Input
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .billAmount:
                self.writeToDiskBillTableIndexPath(indexPath)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
            case .tipAmount:
                self.writeToDiskTipTableIndexPath(indexPath, WithAutoAdjustment: true)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
            }
            self.bigTextLabelsShouldPresent(false)
            let delayTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.scrollViewDidStopMovingForWhateverReason(tableView)
            }
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            self.scrollViewDidStopMovingForWhateverReason(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrollingAnimation(scrollView)
        self.scrollViewDidStopMovingForWhateverReason(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.bigTextLabelsShouldPresent(true)
        if let tableView = scrollView as? UITableView,
            let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag),
            let indexPath = self.indexPathInCenterOfTable(tableView) {
                switch tableTagEnum {
                case .billAmount:
                    self.writeToDiskBillTableIndexPath(indexPath)
                case .tipAmount:
                    self.writeToDiskTipTableIndexPath(indexPath, WithAutoAdjustment: true)
                }
        }
    }
    
    fileprivate func scrollViewDidStopMovingForWhateverReason(_ scrollView: UIScrollView) {
        self.bigTextLabelsShouldPresent(true)
        if let tableView = scrollView as? UITableView,
            let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag),
            let indexPath = self.indexPathInCenterOfTable(tableView) {
                switch tableTagEnum {
                case .billAmount:
                    self.writeToDiskBillTableIndexPath(indexPath)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                case .tipAmount:
                    self.writeToDiskTipTableIndexPath(indexPath, WithAutoAdjustment: true)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                }
        }
        self.postNewCalculationToAnswers()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.bigTextLabelsShouldPresent(false)
        if let tag = TableTagIdentifier(rawValue: scrollView.tag) {
            // these defaults writes keep track of whether a custom tip amount is set
            // without using an instance variable
            switch tag {
            case .billAmount:
                self.writeToDiskTipTableIndexPath(IndexPath(row: 0, section: 0), WithAutoAdjustment: false)
            case .tipAmount:
                self.writeToDiskTipTableIndexPath(IndexPath(row: 1, section: 0), WithAutoAdjustment: false)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let tableTagEnum = TableTagIdentifier(rawValue: scrollView.tag),
            let billAmountTableView = self.billAmountTableView,
            let tipAmountTableView = self.tipAmountTableView,
            let billAmountIndexPath = self.indexPathInCenterOfTable(billAmountTableView),
            let tipAmountIndexPath = self.indexPathInCenterOfTable(tipAmountTableView),
            let billCell = billAmountTableView.cellForRow(at: billAmountIndexPath) as? GratuitousTableViewCell,
            let tipCell = tipAmountTableView.cellForRow(at: tipAmountIndexPath) as? GratuitousTableViewCell {
                let billAmount = billCell.billAmount
                let tipAmount = Int(round((Double(billAmount) * self.applicationPreferences.suggestedTipPercentage)))
                switch tableTagEnum {
                case .billAmount:
                    if self.applicationPreferences.tipIndexPathRow == 0 {
                        let cellOffset = billAmountIndexPath.row - billAmount
                        let adjustedTipIndexPathRow = tipAmount + cellOffset
                        if billAmount > 0 { // this stops a crash when the user scrolls past the end of the billtable
                            tipAmountTableView.scrollToRow(at: IndexPath(row: adjustedTipIndexPathRow, section: 0), at: UITableViewScrollPosition.middle, animated: false)
                        }
                    }
                    self.updateLargeTextLabels(billAmount: billAmount, tipAmount: tipAmount)
                case .tipAmount:
                    let tipAmount = tipCell.billAmount
                    self.updateLargeTextLabels(billAmount: billAmount, tipAmount: tipAmount)
                }
        }
    }
    
    fileprivate func postNewCalculationToAnswers() {
        let c = DefaultsCalculations(preferences: self.applicationPreferences)
        
        var answersAttributes: [String : Any] = [
            "BillAmount" : NSNumber(value: c.billAmount as Int),
            "TipAmount" : NSNumber(value: c.tipAmount as Int),
            "TipPercentage" : NSNumber(value: c.tipPercentage as Int),
            "TotalAmount" : NSNumber(value: c.totalAmount as Int),
            "SystemLocale" : self.currencyFormatter.locale.identifier
        ]
        
        answersAttributes["LocationZipCode"] = self.applicationPreferences.lastLocation?.zipCode
        answersAttributes["LocationCity"] = self.applicationPreferences.lastLocation?.city
        answersAttributes["LocationRegion"] = self.applicationPreferences.lastLocation?.region
        answersAttributes["LocationCountry"] = self.applicationPreferences.lastLocation?.country
        answersAttributes["LocationCountryCode"] = self.applicationPreferences.lastLocation?.countryCode
    }
    
    //MARK: Handle Table View Delegate DataSourceStuff
    
    fileprivate func indexPathInCenterOfTable(_ tableView: UITableView) -> IndexPath? {
        let indexPath: IndexPath?
        
        var point = tableView.frame.origin
        point.x = floor(point.x) + floor(tableView.frame.size.width /? 2)
        point.y = floor(point.y) + floor(tableView.frame.size.height /? 2)
        point = tableView.convert(point, from: tableView.superview)
        if let optionalIndexPath = tableView.indexPathForRow(at: point) {
            indexPath = optionalIndexPath
        } else {
            indexPath = nil
        }
        
        return indexPath !! IndexPath(row: 0, section: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int?
        if let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .billAmount:
                count = self.billAmountsArray.count
            case .tipAmount:
                count = self.tipAmountsArray.count
            }
        } else {
            count = nil
        }
        return count !! 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GratuitousTableViewCell?
        
        if let tableTagEnum = TableTagIdentifier(rawValue: tableView.tag) {
            switch tableTagEnum {
            case .billAmount:
                cell = tableView.dequeueReusableCell(withIdentifier: self.billTableViewCellString) as? GratuitousTableViewCell
            case .tipAmount:
                cell = tableView.dequeueReusableCell(withIdentifier: self.tipTableViewCellString) as? GratuitousTableViewCell
            }
            
            cell?.textSizeAdjustment = self.lowerTextSizeAdjustment
            
            // Need to set the billamount after setting the currency formatter, or else there are bugs.
            switch tableTagEnum {
            case .billAmount:
                cell?.billAmount = self.billAmountsArray[indexPath.row]
            case .tipAmount:
                cell?.billAmount = self.tipAmountsArray[indexPath.row]
            }
        } else {
            cell = nil
        }
        
        return cell !! UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = GratuitousUIConstant.correctCellTextSize().rowHeight()
        
        return rowHeight
    }
    
    //MARK: View Controller Preferences
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    //MARK: Handle Text Size Adjustment and Label Attributed Strings
    
    @objc fileprivate func systemTextSizeDidChange(_ notification: Notification?) {
        DispatchQueue.main.async {
            //adjust text size
            self.lowerTextSizeAdjustment = GratuitousUIConstant.correctCellTextSize().textSizeAdjustment()
            self.selectedTableViewCellOutlineViewHeightConstraint?.constant = GratuitousUIConstant.correctCellTextSize().rowHeight()
            self.largeTextWidthLandscapeOnlyConstraint?.constant = GratuitousUIConstant.largeTextLandscapeConstant()
            self.billAmountTableViewTitleTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
            self.tipAmountTableViewTitleTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
            
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //this line stops a bug with the transforms on rotation
        self.view.transform = CGAffineTransform.identity
        
        coordinator.animate(alongsideTransition: nil, completion: { finished in
            self.updateTableViewsFromDisk()
        })
    }
    
    fileprivate func checkForScreenSizeConstraintAdjustments() {
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
    
    fileprivate func prepareTotalAmountTextLabel() {
        if let totalAmountTextLabel = self.totalAmountTextLabel {
            if let originalFont = GratuitousUIConstant.originalFontForTotalAmountTextLabel() {
                totalAmountTextLabel.font = originalFont
            }
            let font = totalAmountTextLabel.font.withSize(totalAmountTextLabel.font.pointSize * self.upperTextSizeAdjustment)
            let textColor = totalAmountTextLabel.textColor
            let text = totalAmountTextLabel.text
            let shadow = NSShadow()
            shadow.shadowColor = GratuitousUIConstant.textShadowColor()
            shadow.shadowBlurRadius = 2.0
            shadow.shadowOffset = CGSize(width: 2.0, height: 2.0)
            let attributes: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.foregroundColor : textColor!,
                NSAttributedStringKey.font : font,
                //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
                NSAttributedStringKey.shadow : shadow
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
    
    fileprivate func prepareTipPercentageTextLabel() {
        if let tipPercentageTextLabel = self.tipPercentageTextLabel {
            if let originalFont = GratuitousUIConstant.originalFontForTipPercentageTextLabel() {
                tipPercentageTextLabel.font = originalFont
            }
            let font = tipPercentageTextLabel.font.withSize(tipPercentageTextLabel.font.pointSize * self.upperTextSizeAdjustment)
            let textColor = tipPercentageTextLabel.textColor
            let text = tipPercentageTextLabel.text !! ""
            let shadow = NSShadow()
            shadow.shadowColor = GratuitousUIConstant.textShadowColor()
            shadow.shadowBlurRadius = 2.0
            shadow.shadowOffset = CGSize(width: 2.0, height: 2.0)
            let attributes: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.foregroundColor : textColor!,
                NSAttributedStringKey.font : font,
                //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
                NSAttributedStringKey.shadow : shadow
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
        NotificationCenter.default.removeObserver(self)
    }
}

