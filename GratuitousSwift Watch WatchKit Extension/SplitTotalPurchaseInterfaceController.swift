//
//  SplitTotalPurchaseInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/11/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class SplitTotalPurchaseInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var titleLabel: WKInterfaceLabel?
    @IBOutlet private weak var subtitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var descriptionLabel: WKInterfaceLabel?
    
    private let titleTextAttributes = GratuitousUIColor.WatchFonts.splitBillValueText
    private let subtitleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    private let bodyTextAttributes = GratuitousUIColor.WatchFonts.bodyText
    
    override func willActivate() {
        super.willActivate()
        
        self.titleLabel?.setAttributedText(NSAttributedString(string: LocalizedString.TitleTextLabel, attributes: self.titleTextAttributes))
        self.subtitleLabel?.setAttributedText(NSAttributedString(string: LocalizedString.SubtitleTextLabel, attributes: self.subtitleTextAttributes))
        self.descriptionLabel?.setAttributedText(NSAttributedString(string: LocalizedString.DescriptionTextLabel, attributes: self.bodyTextAttributes))
        
        self.updateUserActivity(HandoffTypes.SplitBillPurchase.rawValue, userInfo: ["HandOffKind" : "SplitBillPurchase"], webpageURL: .None)
    }
    
    override func willDisappear() {
        super.willDisappear()
        
        self.invalidateUserActivity()
    }
}
