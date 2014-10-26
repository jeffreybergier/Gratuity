//
//  SettingsViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/25/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var aboutTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
