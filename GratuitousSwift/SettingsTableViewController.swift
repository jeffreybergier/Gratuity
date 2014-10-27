//
//  SettingsViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/25/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var myPictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = GratuitousColorSelector.darkBackgroundColor()
        self.tableView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.myPictureImageView.layer.borderColor = GratuitousColorSelector.lightTextColor().CGColor
        self.myPictureImageView.layer.cornerRadius = self.myPictureImageView.frame.size.width/2
        self.myPictureImageView.layer.borderWidth = 3.0
        self.myPictureImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapDoneButton(sender: UIButton) {
        if let presentingViewController = self.presentingViewController {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
