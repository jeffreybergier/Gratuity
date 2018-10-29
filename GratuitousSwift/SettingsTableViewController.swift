//
//  SettingsViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/25/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import MessageUI
import UIKit

final class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Handle TableViewController
    @IBOutlet fileprivate weak var headerLabelTipPercentage: UILabel?
    @IBOutlet fileprivate weak var headerLabelCurencySymbol: UILabel?
    @IBOutlet fileprivate weak var headerLabelAboutSaturdayApps: UILabel?
    @IBOutlet fileprivate weak var headerLabelInAppPurchases: UILabel?
    
    fileprivate var headerLabelsArray: [UILabel?] = []
    fileprivate lazy var swipeToDismiss: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeToDismiss(_:)))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        return swipe
    }()
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.shared.delegate as! GratuitousAppDelegate).preferencesSetLocally = newValue }
    }
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 320, height: UIScreen.main.bounds.height)
        }
        set { }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizedString.SettingsTitle
        
        //add necessary notification center observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.systemTextSizeDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.percentageMayHaveChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote), object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: .none)
        
        //set the background color of the view
        self.tableView.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
        
        //tell the tableview to have dynamic height
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //set the colors for the navigation controller
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if let restoreIndexPath = self.restoreScrollPosition {
            let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.tableView.scrollToRow(at: restoreIndexPath, at: .top, animated: true)
                self.restoreScrollPosition = .none
            }
        }
        
        //prepare the currency override cells
        self.setInterfaceRefreshNeeded()
    }
    
    @objc fileprivate func applicationDidBecomeActive(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.viewWillAppear(true)
        }
    }
    
    fileprivate func prepareHeaderLabelsAndCells() {
        //prepare the headerlabels
        self.headerLabelsArray = [
            self.headerLabelTipPercentage,
            self.headerLabelCurencySymbol,
            self.headerLabelInAppPurchases,
            self.headerLabelAboutSaturdayApps
        ]
        
        for label in self.headerLabelsArray {
            label?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            label?.textColor = GratuitousUIConstant.darkTextColor()
            label?.superview?.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
            label?.superview?.superview?.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
        }
        
        self.headerLabelTipPercentage?.text = SettingsTableViewController.LocalizedString.SuggestedTipPercentageHeader.uppercased()
        self.headerLabelCurencySymbol?.text = SettingsTableViewController.LocalizedString.CurrencySymbolHeader.uppercased()
        self.headerLabelAboutSaturdayApps?.text = SettingsTableViewController.LocalizedString.AboutHeader.uppercased()
        self.headerLabelInAppPurchases?.text = SettingsTableViewController.LocalizedString.InAppPurchaseHeader.uppercased()
    }
    
    func didTapDoneButton(_ sender: UIButton) {
        if let _ = self.presentingViewController {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func percentageMayHaveChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.prepareTipPercentageSliderAndLabels()
            self.readUserDefaultsAndUpdateSlider()
        }
    }
    
    @objc fileprivate func currencySignChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.setInterfaceRefreshNeeded()
        }
    }
    
    @objc fileprivate func systemTextSizeDidChange(_ notification: Notification?) {
        DispatchQueue.main.async {
            //this takes care of the header cells
            self.prepareHeaderLabelsAndCells()
            
            //set the background color of the view
            self.tableView.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
            self.tableView.tintColor = GratuitousUIConstant.lightTextColor()
            
            //update the percentage slider
            self.prepareTipPercentageSliderAndLabels()
            
            //prepare the tip percentage label that sits on the right of the slider
            self.suggestedTipPercentageLabel?.textColor = GratuitousUIConstant.lightTextColor()
            self.suggestedTipPercentageLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            self.navigationController?.navigationBar.barTintColor = nil
            
            //prepare the in-app purchases cells
            self.prepareInAppPurchaseCells()
            
            //prepare the about area of the table
            self.prepareAboutPictureButtonsAndParagraph()
            
            //prepare the currency override cells
            self.prepareCurrencyIndicatorCells()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Handle Percentage Slider
    @IBOutlet fileprivate weak var suggestedTipPercentageSlider: UISlider?
    @IBOutlet fileprivate weak var suggestedTipPercentageLabel: UILabel?
    
    fileprivate let customThumbImage: UIImage? = {
        // Get the size
        var canvasSize = CGSize(width: 30,height: 30)
        let scale = UIScreen.main.scale
        
        // Resize for retina with the scale factor
        canvasSize.width *= scale
        canvasSize.height *= scale
        
        // Create the context
        UIGraphicsBeginImageContext(canvasSize)
        let currentContext = UIGraphicsGetCurrentContext()
        
        // setup drawing attributes
        currentContext?.setLineWidth(GratuitousUIConstant.thickBorderWidth() * scale);
        currentContext?.setStrokeColor(GratuitousUIConstant.lightBackgroundColor().cgColor);
        currentContext?.setFillColor(GratuitousUIConstant.darkBackgroundColor().cgColor)
        
        // setup the circle size
        var circleRect = CGRect( x: 0, y: 0, width: canvasSize.width, height: canvasSize.height )
        circleRect = circleRect.insetBy(dx: 5, dy: 5)
        
        // Draw the Circle
        currentContext?.fillEllipse(in: circleRect)
        currentContext?.strokeEllipse(in: circleRect)
        
        // Create Image
        let cgImage = currentContext?.makeImage()!
        let image = UIImage(cgImage: cgImage!, scale: scale, orientation: UIImageOrientation.up)
        
        return image
        }()
    
    fileprivate func prepareTipPercentageSliderAndLabels() {
        //set the text color for the tip percentage
        self.suggestedTipPercentageLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        //set the tint color for the tip percentage slider
        self.suggestedTipPercentageSlider?.maximumTrackTintColor = GratuitousUIConstant.lightBackgroundColor()
        
        //set the custom thumb image slider
        if let customThumbImage = self.customThumbImage {
            self.suggestedTipPercentageSlider?.setThumbImage(customThumbImage, for: UIControlState())
        }
        
        //set the background color of the superview of the slider for ipad. For some reason its white on the ipad only
        self.suggestedTipPercentageSlider?.superview?.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
    }
    
    fileprivate func readUserDefaultsAndUpdateSlider() {
        let onDiskTipPercentage = self.applicationPreferences.suggestedTipPercentage
        self.suggestedTipPercentageLabel?.text = "\(Int(round(onDiskTipPercentage * 100)))%"
        self.suggestedTipPercentageSlider?.setValue(Float(onDiskTipPercentage), animated: false)
    }
    
    @IBAction func tipPercentageSliderDidSlide(_ sender: UISlider) {
        //this is called when the value changes... which is all the time
        self.suggestedTipPercentageLabel?.text = String(format: "%.0f%%", sender.value*100)
    }
    
    @IBAction func didChangeSuggestedTipPercentageSlider(_ sender: UISlider) {
        //this is only called when the user lets go of the slider
        let newTipPercentage = sender.value
        self.applicationPreferences.suggestedTipPercentage = Double(newTipPercentage)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "suggestedTipValueUpdated"), object: self)
    }
    
    // MARK: Handle Currency Indicator
    @IBOutlet fileprivate weak var textLabelDefault: UILabel?
    @IBOutlet fileprivate weak var textLabelDollarSign: UILabel?
    @IBOutlet fileprivate weak var textLabelPoundSign: UILabel?
    @IBOutlet fileprivate weak var textLabelEuroSign: UILabel?
    @IBOutlet fileprivate weak var textLabelYenSign: UILabel?
    @IBOutlet fileprivate weak var textLabelNone: UILabel?
    
    fileprivate func prepareCurrencyIndicatorCells() {
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
    
    fileprivate func writeCurrencyOverrideUserDefaultToDisk(_ currencyOverride: CurrencySign? = nil) {
        if let currencyOverride = currencyOverride{
            self.applicationPreferences.overrideCurrencySymbol = currencyOverride
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            //if this is the type of cell, we need to let it know which UILabel is in it
            if let cell = cell as? GratuitousCurrencySelectorCellTableViewCell,
                //this gets called a lot so there is no need to run through the switch unless the cell we're talking to has a nil property.
                let currencySign = CurrencySign(rawValue: cell.tag) {
                    switch currencySign {
                    case .default:
                        self.textLabelDefault?.text = SettingsTableViewController.LocalizedString.LocalCurrencyCellLabel
                        cell.animatableTextLabel = self.textLabelDefault
                    case .dollar:
                        cell.animatableTextLabel = self.textLabelDollarSign
                    case .pound:
                        cell.animatableTextLabel = self.textLabelPoundSign
                    case .euro:
                        cell.animatableTextLabel = self.textLabelEuroSign
                    case .yen:
                        cell.animatableTextLabel = self.textLabelYenSign
                    case .noSign:
                        self.textLabelNone?.text = SettingsTableViewController.LocalizedString.NoneCurrencyCellLabel
                        cell.animatableTextLabel = self.textLabelNone
                    }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let newValue: CurrencySign?
            switch indexPath.row {
            case CurrencySign.default.rawValue + 1:
                newValue = .default
            case CurrencySign.dollar.rawValue + 1:
                newValue = .dollar
            case CurrencySign.pound.rawValue + 1:
                newValue = .pound
            case CurrencySign.euro.rawValue + 1:
                newValue = .euro
            case CurrencySign.yen.rawValue + 1:
                newValue = .yen
            case CurrencySign.noSign.rawValue + 1:
                newValue = .noSign
            default:
                newValue = .none
            }
            if let newValue = newValue {
                self.writeCurrencyOverrideUserDefaultToDisk(newValue)
            }
        case 2:
            switch indexPath.row {
            case 1: // row of splitBill purchase
                let presentingVC = self.presentingViewController
                let purchaseSegue = self.applicationPreferences.splitBillPurchased == true ? TipViewController.StoryboardSegues.SplitBill : TipViewController.StoryboardSegues.PurchaseSplitBill
                self.dismiss(animated: true, completion: { () -> Void in
                    presentingVC?.performSegue(withIdentifier: purchaseSegue.rawValue, sender: self)
                })
            default:
                break
            }
        case 3: // about section
            switch indexPath.row {
            case 3: // Email Me Row
                let emailManager = EmailSupportHandler(kind: .genericEmailSupport, delegate: self)
                if let mailVC = emailManager.presentableMailViewController {
                    self.present(mailVC, animated: true, completion: .none)
                } else {
                    emailManager.switchAppForEmailSupport()
                }
            case 4: // Review this app row
                let appStoreString = String(format: "itms-apps://itunes.apple.com/app/id%d", self.applicationID)
                let appStoreURL = URL(string: appStoreString)
                if let appStoreURL = appStoreURL {
                    UIApplication.shared.openURL(appStoreURL)
                }
            case 5: // Apple Watch Row
                let presentingVC = self.presentingViewController
                self.dismiss(animated: true, completion: { () -> Void in
                    presentingVC?.performSegue(withIdentifier: TipViewController.StoryboardSegues.WatchInfo.rawValue, sender: self)
                })
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: Handle In-App Purchase Cells
    
    @IBOutlet fileprivate weak var splitBillPurchaseLabel: UILabel?
    
    fileprivate func prepareInAppPurchaseCells() {
        self.splitBillPurchaseLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.splitBillPurchaseLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.splitBillPurchaseLabel?.text = SettingsTableViewController.LocalizedString.SplitBillInAppPurchaseCellLabel
    }
    
    
    // MARK: Handle About Information
    @IBOutlet fileprivate weak var aboutMyPictureImageView: UIImageView?
    @IBOutlet fileprivate weak var aboutSaturdayAppsParagraphLabel: UILabel?
    @IBOutlet fileprivate weak var aboutEmailMeLabel: UILabel?
    @IBOutlet fileprivate weak var aboutReviewLabel: UILabel?
    @IBOutlet fileprivate weak var aboutWatchAppLabel: UILabel?
    
    fileprivate let applicationID = 933679671
    
    fileprivate func prepareAboutPictureButtonsAndParagraph() {
        //preparing the picture
        self.aboutMyPictureImageView?.layer.borderColor = GratuitousUIConstant.lightTextColor().cgColor
        let cornerRadius = self.aboutMyPictureImageView?.frame.size.width !! 150.0
        self.aboutMyPictureImageView?.layer.cornerRadius = cornerRadius /? 2.0
        self.aboutMyPictureImageView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.aboutMyPictureImageView?.clipsToBounds = true
        
        //preparing the paragraph text label
        self.aboutSaturdayAppsParagraphLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.aboutSaturdayAppsParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.aboutSaturdayAppsParagraphLabel?.text = SettingsTableViewController.LocalizedString.AboutSADescriptionLabel
        
        //prepare the labels
        let labelFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
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

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
        if let error = error {
            log?.error("Error while sending email. Error Description: \(error.localizedDescription)")
        }
    }
    
    // MARK: Handle UI Changing
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //this line stops a bug with the transforms on rotation
        self.view.transform = CGAffineTransform.identity
        
        coordinator.animate(alongsideTransition: nil, completion: { finished in
            self.tableView.reloadData()
        })
        
    }
    
    // MARK: Handle state restoration
    
    fileprivate var restoreScrollPosition: IndexPath?
    
    override func decodeRestorableState(with coder: NSCoder) {
        self.restoreScrollPosition = coder.decodeObject(forKey: RestoreKeys.ScrollToCellKey) as? IndexPath
        super.decodeRestorableState(with: coder)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        if let indexPath = self.tableView.indexPathsForVisibleRows?.first {
            coder.encode(indexPath, forKey: RestoreKeys.ScrollToCellKey)
        }
        super.encodeRestorableState(with: coder)
    }
    
    struct RestoreKeys {
        static let ScrollToCellKey = "ScrollToCellKey"
    }
    
    // MARK: Handle View Going Away
    func didSwipeToDismiss(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
