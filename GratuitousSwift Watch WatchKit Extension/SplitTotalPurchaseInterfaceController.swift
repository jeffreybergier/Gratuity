//
//  SplitTotalPurchaseInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/11/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class SplitTotalPurchaseInterfaceController: WKInterfaceController {
    
    @IBOutlet fileprivate weak var titleLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var subtitleLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var descriptionLabel: WKInterfaceLabel?
    
    fileprivate let titleTextAttributes = GratuitousUIColor.WatchFonts.splitBillValueText
    fileprivate let subtitleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    fileprivate let bodyTextAttributes = GratuitousUIColor.WatchFonts.bodyText
    
    override func willActivate() {
        super.willActivate()
        
        self.titleLabel?.setAttributedText(NSAttributedString(string: LocalizedString.TitleTextLabel, attributes: self.titleTextAttributes))
        self.subtitleLabel?.setAttributedText(NSAttributedString(string: LocalizedString.SubtitleTextLabel, attributes: self.subtitleTextAttributes))
        self.descriptionLabel?.setAttributedText(NSAttributedString(string: LocalizedString.DescriptionTextLabel, attributes: self.bodyTextAttributes))
        
        self.updateUserActivity(HandoffTypes.SplitBillPurchase.rawValue, userInfo: ["HandOffKind" : "SplitBillPurchase"], webpageURL: .none)
    }
    
    override func willDisappear() {
        super.willDisappear()
        
        self.invalidateUserActivity()
    }
}
