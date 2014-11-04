//
//  SettingsViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/25/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet private weak var myPictureImageView: UIImageView!
    @IBOutlet private weak var suggestedTipPercentageSlider: UISlider!
    @IBOutlet private weak var suggestedTipPercentageLabel: UILabel!
    @IBOutlet private weak var headerLabelTipPercentage: UILabel!
    @IBOutlet private weak var headerLabelCurencySymbol: UILabel!
    @IBOutlet private weak var headerLabelAboutSaturdayApps: UILabel!
    
    private var headerLabelsArray: [UILabel] = []
    //private var headerLabelTextAttributes = [NSString() : NSObject()]
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add necessary notification center observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "readUserDefaultsAndUpdateSlider:", name: "suggestedTipValueUpdated", object: nil)
        
        //set the background color of the view
        self.tableView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        
        //set the colors for the navigation controller
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = GratuitousColorSelector.darkBackgroundColor()
        
        //set the text color for the tip percentage
        self.suggestedTipPercentageLabel.textColor = GratuitousColorSelector.lightTextColor()
        
        //set the tint color for the tip percentage slider
        self.suggestedTipPercentageSlider.setThumbImage(self.suggestedTipPercentageSlider.currentThumbImage, forState: UIControlState.Normal) //this is supposed to be help with an ios7 bug where the thumb tint color doesn't change, but its not working in ios8. more research is needed
        self.suggestedTipPercentageSlider.thumbTintColor = GratuitousColorSelector.lightTextColor()
        self.suggestedTipPercentageSlider.maximumTrackTintColor = UIColor.darkGrayColor()
        
        //configure the border color of my picture in the about screen
        self.myPictureImageView.layer.borderColor = GratuitousColorSelector.lightTextColor().CGColor
        self.myPictureImageView.layer.cornerRadius = self.myPictureImageView.frame.size.width/2
        self.myPictureImageView.layer.borderWidth = 3.0
        self.myPictureImageView.clipsToBounds = true
        
        //prepare the header text labels
        self.prepareHeaderLabelsAndCells()
        
        //lastly, read the defaults from disk and update the UI
        self.readUserDefaultsAndUpdateSlider(nil)
    }
    
    private func prepareHeaderLabelsAndCells() {
        
        //prepare the headerlabels
        self.headerLabelsArray = [self.headerLabelTipPercentage, self.headerLabelCurencySymbol, self.headerLabelAboutSaturdayApps]
        for label in self.headerLabelsArray {
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            label.textColor = UIColor.blackColor()
            label.superview?.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
        }
        
        self.headerLabelTipPercentage.text = NSLocalizedString("Suggested Tip Percentage", comment: "this text is for a section header where the user can set the default tip percentage when they choose a new bill amount").uppercaseString
        self.headerLabelCurencySymbol.text = NSLocalizedString("Currency Symbol", comment: "this text is for a section header where the user can override the currency symbol that will be shown in front of the currency amounts in the app").uppercaseString
        self.headerLabelAboutSaturdayApps.text = NSLocalizedString("About SaturdayApps", comment: "This is a section header. It contains information about my company, saturday apps").uppercaseString
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName("settingsTableViewControllerDidAppear", object: nil)
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

    @IBAction func didTapDoneButton(sender: UIButton) {
        if let presentingViewController = self.presentingViewController {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(nil, completion: { finished in
            self.tableView.reloadData()
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
