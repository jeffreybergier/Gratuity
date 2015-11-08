//
//  GratuitousWatchLocalizedStrings.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

extension SplitTotalPurchaseInterfaceController {
    struct LocalizedString {
        static let TitleTextLabel =
        NSLocalizedString("w001 - Split Bill",
            comment: "Apple Watch App: SplitTotalPurchaseInterfaceController: TitleLabel: Title for Split Bill Feature."
        )
        static let SubtitleTextLabel =
        NSLocalizedString("w002 - In-App Purchase",
            comment: "Apple Watch App: SplitTotalPurchaseInterfaceController: SubtitleLabel: Whatever Apple calls In-App Purchase locally"
        )
        static let DescriptionTextLabel =
        NSLocalizedString("w003 - Handoff to your iPhone to purchase.",
            comment: "Apple Watch App: SplitTotalPurchaseInterfaceController: DescriptionTextLabel: Short instructions to use handoff to buy on your iPhone."
        )
    }
}

extension SplitTotalInterfaceController {
    struct LocalizedString {
        static let SplitBillTitleLabel =
        NSLocalizedString("w004 - Split Bill",
            comment: "Apple Watch App: SplitTotalInterfaceController: TitleLabel: Title for Split Bill Feature."
        )
        static let CloseSplitBillTitle =
        NSLocalizedString("w005 - Close",
            comment: "Apple Watch App: SplitTotalInterfaceController: CloseSplitBillTitle: This is the title of the Split Bill screen. The title doubles as the close the button."
        )
    }
}

extension PickerInterfaceController {
    struct LocalizedString {
        static let SplitTipMenuIconLabel =
        NSLocalizedString("w006 - Split Bill",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Text for the menu item that opens the split tip feature."
        )
        static let SettingsMenuIconLabel =
        NSLocalizedString("w007 - Settings",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Text for the menu item that opens the settings screen."
        )
        static let TipItemPickerCaption =
        NSLocalizedString("w008 - Tip",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Callout that appears above Tip Picker wheel when selected."
        )
        static let BillItemPickerCaption =
        NSLocalizedString("w009 - Bill",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Callout that appears above Bill Picker wheel when selected."
        )
        static let InterfaceTitle =
        NSLocalizedString("w010 - Gratuity",
            comment: "Apple Watch App: PickerInterfaceController: InterfaceTitle: Gratuity app name for the main interface."
        )
    }
}

extension SettingsInterfaceController {
    struct LocalizedString {
        static let CloseSettingsTitle =
        NSLocalizedString("w011 - Close",
            comment: "Apple Watch App: SettingsInterfaceController: CloseSettingsTitle: This is the title of the Settings screen. The title doubles as the close the button."
        )
        static let SuggestedTipPercentageHeader =
        NSLocalizedString("w012 - Suggested Tip Percentage",
            comment: "Apple Watch App: SettingsInterfaceController: SuggestedTipPercentageHeader: Header Text for a group of cells that allow choosing the default tip percentage."
        )
        static let CurrencySymbolHeader =
        NSLocalizedString("w013 - Currency Symbol",
            comment: "Apple Watch App: SettingsInterfaceController: CurrencySymbolHeader: Header Text for a group of cells that allow choosing the currency symbol."
        )
        static let LocalCurrencyRowLabel =
        NSLocalizedString("w014 - Local",
            comment: "Apple Watch App: SettingsInterfaceController: LocalCurrencyRowLabel: Cell that tells the system to use the regional currency symbol."
        )
        static let NoneCurrencyRowLabel =
        NSLocalizedString("w015 - None",
            comment: "Apple Watch App: SettingsInterfaceController: NoneCurrencyRowLabel: Cell that tells the system to use no currency symbol."
        )
    }
}









