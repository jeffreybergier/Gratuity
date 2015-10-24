//
//  SettingsViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/25/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import MessageUI
import XCGLogger
import Crashlytics

final class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Handle TableViewController
    @IBOutlet private weak var headerLabelTipPercentage: UILabel?
    @IBOutlet private weak var headerLabelCurencySymbol: UILabel?
    @IBOutlet private weak var headerLabelAboutSaturdayApps: UILabel?
    @IBOutlet private weak var headerLabelInAppPurchases: UILabel?
    
    private let log = XCGLogger.defaultInstance()

    private var headerLabelsArray: [UILabel?] = []
    private lazy var swipeToDismiss: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: "didSwipeToDismiss:")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        return swipe
    }()
    private var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferencesSetLocally = newValue }
    }
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 320, height: UIScreen.mainScreen().bounds.height)
        }
        set { }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add necessary notification center observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: NSCurrentLocaleDidChangeNotification, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "percentageMayHaveChanged:", name: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: .None)
        
        //set the background color of the view
        self.tableView.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
        
        //tell the tableview to have dynamic height
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //set the colors for the navigation controller
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = nil
        
        //these lines are not needed because I switched to segues. But I do like this code because its more adaptable.
        /*
        //set up the right Done button in the navigation bar
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "didTapDoneButton:")
        self.navigationItem.rightBarButtonItem = doneButton
        */
        
        //set the text color for the tip percentage
        self.prepareTipPercentageSliderAndLabels()
        
        //add the dismiss gesture recognizer to the view
        self.view.addGestureRecognizer(self.swipeToDismiss)
        
        //prepare in-app purchases cells
        self.prepareInAppPurchaseCells()
        
        //configure the border color of my picture in the about screen
        self.prepareAboutPictureButtonsAndParagraph()
        
        //prepare the header text labels
        self.prepareHeaderLabelsAndCells()
        
        //lastly, read the defaults from disk and update the UI
        self.readUserDefaultsAndUpdateSlider()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        if let restoreIndexPath = self.restoreScrollPosition {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.tableView.scrollToRowAtIndexPath(restoreIndexPath, atScrollPosition: .Top, animated: true)
                self.restoreScrollPosition = .None
            }
        }
        
        //prepare the currency override cells
        self.setInterfaceRefreshNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentViewWithName(AnswersString.ViewDidAppear, contentType: .None, contentId: .None, customAttributes: .None)
    }
    
    @objc private func applicationDidBecomeActive(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.viewWillAppear(true)
        }
    }
    
    private func prepareHeaderLabelsAndCells() {
        //prepare the headerlabels
        self.headerLabelsArray = [
            self.headerLabelTipPercentage,
            self.headerLabelCurencySymbol,
            self.headerLabelInAppPurchases,
            self.headerLabelAboutSaturdayApps
        ]
        
        for label in self.headerLabelsArray {
            label?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            label?.textColor = GratuitousUIConstant.darkTextColor()
            label?.superview?.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
            label?.superview?.superview?.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
        }
        
        self.headerLabelTipPercentage?.text = SettingsTableViewController.LocalizedString.SuggestedTipPercentageHeader.uppercaseString
        self.headerLabelCurencySymbol?.text = SettingsTableViewController.LocalizedString.CurrencySymbolHeader.uppercaseString
        self.headerLabelAboutSaturdayApps?.text = SettingsTableViewController.LocalizedString.AboutHeader.uppercaseString
        self.headerLabelInAppPurchases?.text = SettingsTableViewController.LocalizedString.InAppPurchaseHeader.uppercaseString
    }
    
    func didTapDoneButton(sender: UIButton) {
        if let _ = self.presentingViewController {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @objc private func percentageMayHaveChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.prepareTipPercentageSliderAndLabels()
            self.readUserDefaultsAndUpdateSlider()
        }
    }
    
    @objc private func currencySignChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.setInterfaceRefreshNeeded()
        }
    }
    
    @objc private func systemTextSizeDidChange(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            //this takes care of the header cells
            self.prepareHeaderLabelsAndCells()
            
            //set the background color of the view
            self.tableView.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
            self.tableView.tintColor = GratuitousUIConstant.lightTextColor()
            
            //update the percentage slider
            self.prepareTipPercentageSliderAndLabels()
            
            //prepare the tip percentage label that sits on the right of the slider
            self.suggestedTipPercentageLabel?.textColor = GratuitousUIConstant.lightTextColor()
            self.suggestedTipPercentageLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            self.navigationController?.navigationBar.barTintColor = nil
            
            //prepare the in-app purchases cells
            self.prepareInAppPurchaseCells()
            
            //prepare the about area of the table
            self.prepareAboutPictureButtonsAndParagraph()
            
            //prepare the currency override cells
            self.prepareCurrencyIndicatorCells()
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Handle Percentage Slider
    @IBOutlet private weak var suggestedTipPercentageSlider: UISlider?
    @IBOutlet private weak var suggestedTipPercentageLabel: UILabel?
    
    private let customThumbImage: UIImage? = {
        // Get the size
        var canvasSize = CGSizeMake(30,30)
        let scale = UIScreen.mainScreen().scale
        
        // Resize for retina with the scale factor
        canvasSize.width *= scale
        canvasSize.height *= scale
        
        // Create the context
        UIGraphicsBeginImageContext(canvasSize)
        let currentContext = UIGraphicsGetCurrentContext()
        
        // setup drawing attributes
        CGContextSetLineWidth(currentContext, GratuitousUIConstant.thickBorderWidth() * scale);
        CGContextSetStrokeColorWithColor(currentContext, GratuitousUIConstant.lightBackgroundColor().CGColor);
        CGContextSetFillColorWithColor(currentContext, GratuitousUIConstant.darkBackgroundColor().CGColor)
        
        // setup the circle size
        var circleRect = CGRectMake( 0, 0, canvasSize.width, canvasSize.height )
        circleRect = CGRectInset(circleRect, 5, 5)
        
        // Draw the Circle
        CGContextFillEllipseInRect(currentContext, circleRect)
        CGContextStrokeEllipseInRect(currentContext, circleRect)
        
        // Create Image
        let cgImage = CGBitmapContextCreateImage(currentContext)!
        let image = UIImage(CGImage: cgImage, scale: scale, orientation: UIImageOrientation.Up)
        
        return image
        }()
    
    private func prepareTipPercentageSliderAndLabels() {
        //set the text color for the tip percentage
        self.suggestedTipPercentageLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        //set the tint color for the tip percentage slider
        self.suggestedTipPercentageSlider?.maximumTrackTintColor = GratuitousUIConstant.lightBackgroundColor()
        
        //set the custom thumb image slider
        if let customThumbImage = self.customThumbImage {
            self.suggestedTipPercentageSlider?.setThumbImage(customThumbImage, forState: UIControlState.Normal)
        }
        
        //set the background color of the superview of the slider for ipad. For some reason its white on the ipad only
        self.suggestedTipPercentageSlider?.superview?.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
    }
    
    private func readUserDefaultsAndUpdateSlider() {
        let onDiskTipPercentage = self.applicationPreferences.suggestedTipPercentage
        self.suggestedTipPercentageLabel?.text = "\(Int(round(onDiskTipPercentage * 100)))%"
        self.suggestedTipPercentageSlider?.setValue(Float(onDiskTipPercentage), animated: false)
    }
    
    @IBAction func tipPercentageSliderDidSlide(sender: UISlider) {
        //this is called when the value changes... which is all the time
        self.suggestedTipPercentageLabel?.text = String(format: "%.0f%%", sender.value*100)
    }
    
    @IBAction func didChangeSuggestedTipPercentageSlider(sender: UISlider) {
        let attributes = [
            "OldValue" : NSNumber(integer: Int(round(self.applicationPreferences.suggestedTipPercentage * 100))),
            "NewValue" : NSNumber(integer: Int(round(sender.value * 100)))
        ]
        Answers.logCustomEventWithName(AnswersString.DidChangeTipPercentage, customAttributes: attributes)
        //this is only called when the user lets go of the slider
        let newTipPercentage = sender.value
        self.applicationPreferences.suggestedTipPercentage = Double(newTipPercentage)
        NSNotificationCenter.defaultCenter().postNotificationName("suggestedTipValueUpdated", object: self)
    }
    
    // MARK: Handle Currency Indicator
    @IBOutlet private weak var textLabelDefault: UILabel?
    @IBOutlet private weak var textLabelDollarSign: UILabel?
    @IBOutlet private weak var textLabelPoundSign: UILabel?
    @IBOutlet private weak var textLabelEuroSign: UILabel?
    @IBOutlet private weak var textLabelYenSign: UILabel?
    @IBOutlet private weak var textLabelNone: UILabel?
    
    private func prepareCurrencyIndicatorCells() {
        self.writeCurrencyOverrideUserDefaultToDisk()
    }
    
    func setInterfaceRefreshNeeded() {
        if let cells = self.tableView?.visibleCells {
            cells.forEach() { genericCell in
                if let cell = genericCell as? GratuitousCurrencySelectorCellTableViewCell {
                    cell.setInterfaceRefreshNeeded()
                }
            }
        }
    }
    
    private func writeCurrencyOverrideUserDefaultToDisk(currencyOverride: CurrencySign? = nil) {
        if let currencyOverride = currencyOverride{
            self.applicationPreferences.overrideCurrencySymbol = currencyOverride
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            //if this is the type of cell, we need to let it know which UILabel is in it
            if let cell = cell as? GratuitousCurrencySelectorCellTableViewCell,
                //this gets called a lot so there is no need to run through the switch unless the cell we're talking to has a nil property.
                let currencySign = CurrencySign(rawValue: cell.tag) {
                    switch currencySign {
                    case .Default:
                        self.textLabelDefault?.text = SettingsTableViewController.LocalizedString.LocalCurrencyCellLabel
                        cell.animatableTextLabel = self.textLabelDefault
                    case .Dollar:
                        cell.animatableTextLabel = self.textLabelDollarSign
                    case .Pound:
                        cell.animatableTextLabel = self.textLabelPoundSign
                    case .Euro:
                        cell.animatableTextLabel = self.textLabelEuroSign
                    case .Yen:
                        cell.animatableTextLabel = self.textLabelYenSign
                    case .NoSign:
                        self.textLabelNone?.text = SettingsTableViewController.LocalizedString.NoneCurrencyCellLabel
                        cell.animatableTextLabel = self.textLabelNone
                    }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            let newValue: CurrencySign?
            let oldValue = self.applicationPreferences.overrideCurrencySymbol
            switch indexPath.row {
            case CurrencySign.Default.rawValue + 1:
                newValue = .Default
            case CurrencySign.Dollar.rawValue + 1:
                newValue = .Dollar
            case CurrencySign.Pound.rawValue + 1:
                newValue = .Pound
            case CurrencySign.Euro.rawValue + 1:
                newValue = .Euro
            case CurrencySign.Yen.rawValue + 1:
                newValue = .Yen
            case CurrencySign.NoSign.rawValue + 1:
                newValue = .NoSign
            default:
                newValue = .None
            }
            if let newValue = newValue {
                self.writeCurrencyOverrideUserDefaultToDisk(newValue)
                let attributes = ["NewValue" : newValue.descriptionForAnswers, "OldValue" : oldValue.descriptionForAnswers]
                Answers.logCustomEventWithName(AnswersString.DidChangeCurrencySymbol, customAttributes: attributes)
            }
        case 2:
            switch indexPath.row {
            case 1: // row of splitBill purchase
                let presentingVC = self.presentingViewController
                let purchaseSegue = self.applicationPreferences.splitBillPurchased == true ? TipViewController.StoryboardSegues.SplitBill : TipViewController.StoryboardSegues.PurchaseSplitBill
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    presentingVC?.performSegueWithIdentifier(purchaseSegue.rawValue, sender: self)
                })
            default:
                break
            }
        case 3: // about section
            switch indexPath.row {
            case 3: // Email Me Row
                let emailManager = EmailSupportHandler(type: .GenericEmailSupport, delegate: self)
                if let mailVC = emailManager.presentableMailViewController {
                    Answers.logContentViewWithName(AnswersString.DidOpenInternalEmail, contentType: .None, contentId: .None, customAttributes: .None)
                    self.presentViewController(mailVC, animated: true, completion: .None)
                } else {
                    Answers.logContentViewWithName(AnswersString.DidOpenExternalEmail, contentType: .None, contentId: .None, customAttributes: .None)
                    emailManager.switchAppForEmailSupport()
                }
            case 4: // Review this app row
                let appStoreString = String(format: "itms-apps://itunes.apple.com/app/id%d", self.applicationID)
                let appStoreURL = NSURL(string: appStoreString)
                if let appStoreURL = appStoreURL {
                    Answers.logContentViewWithName(AnswersString.DidTapReview, contentType: .None, contentId: .None, customAttributes: .None)
                    UIApplication.sharedApplication().openURL(appStoreURL)
                }
            case 5: // Apple Watch Row
                let presentingVC = self.presentingViewController
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    presentingVC?.performSegueWithIdentifier(TipViewController.StoryboardSegues.WatchInfo.rawValue, sender: self)
                })
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: Handle In-App Purchase Cells
    
    @IBOutlet private weak var splitBillPurchaseLabel: UILabel?
    
    private func prepareInAppPurchaseCells() {
        self.splitBillPurchaseLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.splitBillPurchaseLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.splitBillPurchaseLabel?.text = SettingsTableViewController.LocalizedString.SplitBillInAppPurchaseCellLabel
    }
    
    
    // MARK: Handle About Information
    @IBOutlet private weak var aboutMyPictureImageView: UIImageView?
    @IBOutlet private weak var aboutSaturdayAppsParagraphLabel: UILabel?
    @IBOutlet private weak var aboutEmailMeLabel: UILabel?
    @IBOutlet private weak var aboutReviewLabel: UILabel?
    @IBOutlet private weak var aboutWatchAppLabel: UILabel?
    
    private let applicationID = 933679671
    
    private func prepareAboutPictureButtonsAndParagraph() {
        //preparing the picture
        self.aboutMyPictureImageView?.layer.borderColor = GratuitousUIConstant.lightTextColor().CGColor
        let cornerRadius = self.aboutMyPictureImageView?.frame.size.width !! 150.0
        self.aboutMyPictureImageView?.layer.cornerRadius = cornerRadius / 2.0
        self.aboutMyPictureImageView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.aboutMyPictureImageView?.clipsToBounds = true
        
        //preparing the paragraph text label
        self.aboutSaturdayAppsParagraphLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.aboutSaturdayAppsParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.aboutSaturdayAppsParagraphLabel?.text = SettingsTableViewController.LocalizedString.AboutSADescriptionLabel
        
        //prepare the labels
        let labelFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        let labelTextColor = GratuitousUIConstant.lightTextColor()

        self.aboutEmailMeLabel?.font = labelFont
        self.aboutReviewLabel?.font = labelFont
        self.aboutWatchAppLabel?.font = labelFont
        
        self.aboutEmailMeLabel?.textColor = labelTextColor
        self.aboutReviewLabel?.textColor = labelTextColor
        self.aboutWatchAppLabel?.textColor = labelTextColor
        
        self.aboutEmailMeLabel?.text = UIAlertAction.Gratuity.LocalizedString.EmailSupport
        self.aboutReviewLabel?.text = SettingsTableViewController.LocalizedString.ReviewThisAppButton
        self.aboutWatchAppLabel?.text = SettingsTableViewController.LocalizedString.GratuityForAppleWatchButton
        
        //set the background color of all of the different cells. For some reason on ipad, its white instead of clear
        self.aboutMyPictureImageView?.superview?.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
        self.aboutSaturdayAppsParagraphLabel?.superview?.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        if let error = error {
            self.log.error("Error while sending email. Error Description: \(error.localizedDescription)")
        }
        
        switch result {
        case MFMailComposeResultCancelled:
            Answers.logCustomEventWithName(AnswersString.DidCancelEmail, customAttributes: error?.dictionaryForAnswers)
        case MFMailComposeResultSent:
            Answers.logCustomEventWithName(AnswersString.DidSendEmail, customAttributes: error?.dictionaryForAnswers)
        case MFMailComposeResultSaved:
            Answers.logCustomEventWithName(AnswersString.DidSaveEmail, customAttributes: error?.dictionaryForAnswers)
        case MFMailComposeResultFailed:
            Answers.logCustomEventWithName(AnswersString.DidFailEmail, customAttributes: error?.dictionaryForAnswers)
        default:
            break
        }
    }
    
    // MARK: Handle UI Changing
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        //this line stops a bug with the transforms on rotation
        self.view.transform = CGAffineTransformIdentity
        
        coordinator.animateAlongsideTransition(nil, completion: { finished in
            self.tableView.reloadData()
        })
        
    }
    
    // MARK: Handle state restoration
    
    private var restoreScrollPosition: NSIndexPath?
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        self.restoreScrollPosition = coder.decodeObjectForKey(RestoreKeys.ScrollToCellKey) as? NSIndexPath
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        if let indexPath = self.tableView.indexPathsForVisibleRows?.first {
            coder.encodeObject(indexPath, forKey: RestoreKeys.ScrollToCellKey)
        }
        super.encodeRestorableStateWithCoder(coder)
    }
    
    struct RestoreKeys {
        static let ScrollToCellKey = "ScrollToCellKey"
    }
    
    // MARK: Handle View Going Away
    func didSwipeToDismiss(sender: UISwipeGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
