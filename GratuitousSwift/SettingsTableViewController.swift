//
//  SettingsViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/25/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Handle TableViewController
    @IBOutlet private weak var headerLabelTipPercentage: UILabel!
    @IBOutlet private weak var headerLabelCurencySymbol: UILabel!
    @IBOutlet private weak var headerLabelAboutSaturdayApps: UILabel!
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private var headerLabelsArray: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make this view use a custom transition context
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        //add necessary notification center observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "readUserDefaultsAndUpdateSlider:", name: "suggestedTipValueUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        //set the background color of the view
        self.tableView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        
        //set the colors for the navigation controller
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = nil
        
        //set up the right Done button in the navigation bar
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "didTapDoneButton:")
        self.navigationItem.rightBarButtonItem = doneButton
        
        //set the text color for the tip percentage
        self.prepareTipPercentageSliderAndLabels()
        
        //configure the border color of my picture in the about screen
        self.prepareAboutPictureButtonsAndParagraph()
        
        //prepare the header text labels
        self.prepareHeaderLabelsAndCells()
        
        //lastly, read the defaults from disk and update the UI
        self.readUserDefaultsAndUpdateSlider(nil)
    }
    
    private func prepareHeaderLabelsAndCells() {
        //prepare the headerlabels
        self.headerLabelsArray = [
            self.headerLabelTipPercentage,
            self.headerLabelCurencySymbol,
            self.headerLabelAboutSaturdayApps
        ]
        
        for label in self.headerLabelsArray {
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            label.textColor = UIColor.blackColor()
            label.superview?.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
            label.superview?.superview?.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        }
        
        self.headerLabelTipPercentage.text = NSLocalizedString("Suggested Tip Percentage", comment: "this text is for a section header where the user can set the default tip percentage when they choose a new bill amount").uppercaseString
        self.headerLabelCurencySymbol.text = NSLocalizedString("Currency Symbol", comment: "this text is for a section header where the user can override the currency symbol that will be shown in front of the currency amounts in the app").uppercaseString
        self.headerLabelAboutSaturdayApps.text = NSLocalizedString("About SaturdayApps", comment: "This is a section header. It contains information about my company, saturday apps").uppercaseString
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //prepare the currency override cells
        self.prepareCurrencyIndicatorCells()
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
                
        NSNotificationCenter.defaultCenter().postNotificationName("settingsTableViewControllerDidAppear", object: nil)
    }
    
    @IBAction func didTapDoneButton(sender: UIButton) {
        if let presentingViewController = self.presentingViewController {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func systemTextSizeDidChange(notification:NSNotification) {
        //this takes care of the header cells
        self.prepareHeaderLabelsAndCells()
        
        //prepare the tip percentage label that sits on the right of the slider
        self.suggestedTipPercentageLabel.textColor = GratuitousColorSelector.lightTextColor()
        self.suggestedTipPercentageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        //prepare the about area of the table
        self.prepareAboutPictureButtonsAndParagraph()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: Handle Percentage Slider
    @IBOutlet private weak var suggestedTipPercentageSlider: UISlider!
    @IBOutlet private weak var suggestedTipPercentageLabel: UILabel!
    
    func prepareTipPercentageSliderAndLabels() {
        //set the text color for the tip percentage
        self.suggestedTipPercentageLabel.textColor = GratuitousColorSelector.lightTextColor()
        
        //set the tint color for the tip percentage slider
        self.suggestedTipPercentageSlider.maximumTrackTintColor = UIColor.blackColor()
        
        //set the background color of the superview of the slider for ipad. For some reason its white on the ipad only
        self.suggestedTipPercentageSlider.superview?.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
    }
    
    func readUserDefaultsAndUpdateSlider(notification: NSNotification?) {
        let onDiskTipPercentage:NSNumber = self.userDefaults.doubleForKey("suggestedTipPercentage")
        self.suggestedTipPercentageLabel.text = NSString(format: "%.0f%%", onDiskTipPercentage.floatValue*100)
        self.suggestedTipPercentageSlider.setValue(onDiskTipPercentage.floatValue, animated: false)
    }
    
    @IBAction func tipPercentageSliderDidSlide(sender: UISlider) {
        //this is called when the value changes... which is all the time
        self.suggestedTipPercentageLabel.text = NSString(format: "%.0f%%", sender.value*100)
    }
    
    @IBAction func didChangeSuggestedTipPercentageSlider(sender: UISlider) {
        //this is only called when the user lets go of the slider
        let newTipPercentage: NSNumber = sender.value
        self.userDefaults.setDouble(newTipPercentage.doubleValue, forKey: "suggestedTipPercentage")
        self.userDefaults.synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName("suggestedTipValueUpdated", object: self)
    }
    
    // MARK: Handle Currency Indicator
    @IBOutlet private weak var textLabelDefault: UILabel!
    @IBOutlet private weak var textLabelDollarSign: UILabel!
    @IBOutlet private weak var textLabelPoundSign: UILabel!
    @IBOutlet private weak var textLabelEuroSign: UILabel!
    @IBOutlet private weak var textLabelYenSign: UILabel!
    @IBOutlet private weak var textLabelNone: UILabel!
    
    private var textLabelsArray: [UILabel] = []
    
    func prepareCurrencyIndicatorCells() {
        self.textLabelsArray = [
            self.textLabelDefault,
            self.textLabelDollarSign,
            self.textLabelPoundSign,
            self.textLabelEuroSign,
            self.textLabelYenSign,
            self.textLabelNone
        ]
        
        
        //this crazy lump fixes a small visual bug having to do with the border of the cell for the selected cell
        let userDefaults = NSUserDefaults.standardUserDefaults()
        for i in 0..<6 {
            //uhhhh for some reason just running cellforrowatindexpath fixes this issue. really strange
            let indexPath = NSIndexPath(forRow: i+1, inSection: 1)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        }
        
        
        self.writeCurrencyOverrideUserDefaultToDisk(nil)
    }
    
    private func writeCurrencyOverrideUserDefaultToDisk(currencyOverride: Int?) {
        if let currencyOverride = currencyOverride {
            self.userDefaults.setInteger(currencyOverride, forKey: "overrideCurrencySymbol")
            self.userDefaults.synchronize()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("overrideCurrencySymbolUpdatedOnDisk", object: self)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            //if this is the type of cell, we need to let it know which UILabel is in it
            if let cell = cell as? GratuitousCurrencySelectorCellTableViewCell {
                //this gets called a lot so there is no need to run through the switch unless the cell we're talking to has a nil property.
                if cell.instanceTextLabel == nil {
                    switch cell.tag {
                    case CurrencySign.Default.rawValue:
                        self.textLabelDefault.text = NSLocalizedString("Local Currency", comment: "This is a selector so the user can choose which currency symbol to show in the tip calculator. This option tells the app to use the local currency symbol based on the Locale set in the iphone")
                        cell.instanceTextLabel = self.textLabelDefault
                    case CurrencySign.Dollar.rawValue:
                        cell.instanceTextLabel = self.textLabelDollarSign
                    case CurrencySign.Pound.rawValue:
                        cell.instanceTextLabel = self.textLabelPoundSign
                    case CurrencySign.Euro.rawValue:
                        cell.instanceTextLabel = self.textLabelEuroSign
                    case CurrencySign.Yen.rawValue:
                        cell.instanceTextLabel = self.textLabelYenSign
                    case CurrencySign.None.rawValue:
                        self.textLabelNone.text = NSLocalizedString("No Symbol", comment: "This is a selector so the user can choose which currency symbol to show in the tip calculator. This option tells the app to use no currency symbol")
                        cell.instanceTextLabel = self.textLabelNone
                    default:
                        break;
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            println("selected tableview cell index = \(indexPath.row)")
            switch indexPath.row {
            case CurrencySign.Default.rawValue + 1:
                self.writeCurrencyOverrideUserDefaultToDisk(CurrencySign.Default.rawValue)
            case CurrencySign.Dollar.rawValue + 1:
                self.writeCurrencyOverrideUserDefaultToDisk(CurrencySign.Dollar.rawValue)
            case CurrencySign.Pound.rawValue + 1:
                self.writeCurrencyOverrideUserDefaultToDisk(CurrencySign.Pound.rawValue)
            case CurrencySign.Euro.rawValue + 1:
                self.writeCurrencyOverrideUserDefaultToDisk(CurrencySign.Euro.rawValue)
            case CurrencySign.Yen.rawValue + 1:
                self.writeCurrencyOverrideUserDefaultToDisk(CurrencySign.Yen.rawValue)
            case CurrencySign.None.rawValue + 1:
                self.writeCurrencyOverrideUserDefaultToDisk(CurrencySign.None.rawValue)
            default:
                break;
            }
        default:
            break;
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: Handle About Information
    @IBOutlet private weak var aboutMyPictureImageView: UIImageView!
    @IBOutlet private weak var aboutSaturdayAppsParagraphLabel: UILabel!
    @IBOutlet private weak var aboutEmailMeButton: UIButton!
    @IBOutlet private weak var aboutReviewButton: UIButton!
    
    private let applicationID = 933679671
    
    private func prepareAboutPictureButtonsAndParagraph() {
        //preparing the picture
        self.aboutMyPictureImageView.layer.borderColor = GratuitousColorSelector.lightTextColor().CGColor
        self.aboutMyPictureImageView.layer.cornerRadius = self.aboutMyPictureImageView.frame.size.width/2
        self.aboutMyPictureImageView.layer.borderWidth = 3.0
        self.aboutMyPictureImageView.clipsToBounds = true
        
        //preparing the paragraph text label
        self.aboutSaturdayAppsParagraphLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.aboutSaturdayAppsParagraphLabel.textColor = GratuitousColorSelector.lightTextColor()
        self.aboutSaturdayAppsParagraphLabel.text = NSLocalizedString("My name is Jeff. I'm a professional designer. I like making Apps in my spare time. The many examples of tip calculators on the App Store didn't match the tipping paradigm I used in restaurants. So I made Gratuity. If you like it, email me or leave a review on the app store.", comment: "")
        
        //prepare the buttons
        self.aboutEmailMeButton.setTitle(NSLocalizedString("Email Me", comment: "this is the button that users can use to send me an email."), forState: UIControlState.Normal)
        self.aboutReviewButton.setTitle(NSLocalizedString("Review This App", comment: "this button takes the user to the app store so they can leave a review"), forState: UIControlState.Normal)
        
        //set the background color of all of the different cells. For some reason on ipad, its white instead of clear
        self.aboutMyPictureImageView.superview?.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.aboutSaturdayAppsParagraphLabel.superview?.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.aboutEmailMeButton.superview?.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.aboutReviewButton.superview?.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
    }
    
    @IBAction func didTapEmailMeButton(sender: UIButton) {
        let subject = NSLocalizedString("I love Gratuity", comment: "This is the subject line of support requests. It should say something positive about the app but its mostly gonna be used when people are upset")
        let body = NSLocalizedString("", comment: "this is the body line of support requests, it should be blank, but the possibilies are endless")
        
        if MFMailComposeViewController.canSendMail() {
            let mailer = MFMailComposeViewController()
            mailer.mailComposeDelegate = self
            mailer.setSubject(subject)
            mailer.setToRecipients(["support@saturdayapps.com"])
            mailer.setMessageBody(body, isHTML: false)
            
            self.presentViewController(mailer, animated: true, completion: nil)
        } else {
            let mailStringWrongEncoding = NSString(format: "mailto:support@saturdayapps.com?subject=%@&body=%@", subject, body)
            let mailString = mailStringWrongEncoding.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            if let mailString = mailString {
                let mailToURL = NSURL(string: mailString)
                if let mailToURL = mailToURL {
                    UIApplication.sharedApplication().openURL(mailToURL)
                }
            }
        }
    }
    
    @IBAction func didTapReviewThisAppButton(sender: UIButton) {
        let appStoreString = NSString(format: "itms-apps://itunes.apple.com/app/%f", self.applicationID)
        let appStoreURL = NSURL(string: appStoreString)
        if let appStoreURL = appStoreURL {
            UIApplication.sharedApplication().openURL(appStoreURL)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        if error != nil {
            println("AboutTableViewController: Error while sending email. Error Description: \(error.description)")
        }
    }
    
    // MARK: Handle UI Changing
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(nil, completion: { finished in
            self.tableView.reloadData()
        })
    }
    
    // MARK: Handle View Going Away
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
