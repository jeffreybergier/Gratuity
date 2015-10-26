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
        NSLocalizedString("1 - Split Bill",
            comment: "Apple Watch App: SplitTotalPurchaseInterfaceController: TitleLabel: Title for Split Bill Feature."
        )
        static let SubtitleTextLabel =
        NSLocalizedString("1 - In-App Purchase",
            comment: "Apple Watch App: SplitTotalPurchaseInterfaceController: SubtitleLabel: Whatever Apple calls In-App Purchase locally"
        )
        static let DescriptionTextLabel =
        NSLocalizedString("Handoff to your iPhone to purchase.",
            comment: "Apple Watch App: SplitTotalPurchaseInterfaceController: DescriptionTextLabel: Short instructions to use handoff to buy on your iPhone."
        )
    }
}

extension SplitTotalInterfaceController {
    struct LocalizedString {
        static let SplitBillTitleLabel =
        NSLocalizedString("2 - Split Bill",
            comment: "Apple Watch App: SplitTotalInterfaceController: TitleLabel: Title for Split Bill Feature."
        )
        static let CloseSplitBillTitle =
        NSLocalizedString("1 - Close",
            comment: "Apple Watch App: SplitTotalInterfaceController: CloseSplitBillTitle: This is the title of the Split Bill screen. The title doubles as the close the button."
        )
    }
}

extension PickerInterfaceController {
    struct LocalizedString {
        static let SplitTipMenuIconLabel =
        NSLocalizedString("5 - Split Bill",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Text for the menu item that opens the split tip feature."
        )
        static let SettingsMenuIconLabel =
        NSLocalizedString("1 - Settings",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Text for the menu item that opens the settings screen."
        )
        static let TipItemPickerCaption =
        NSLocalizedString("Tip",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Callout that appears above Tip Picker wheel when selected."
        )
        static let BillItemPickerCaption =
        NSLocalizedString("Bill",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Callout that appears above Bill Picker wheel when selected."
        )
        static let InterfaceTitle =
        NSLocalizedString("2 - Gratuity",
            comment: "Apple Watch App: PickerInterfaceController: InterfaceTitle: Gratuity app name for the main interface."
        )
    }
}

extension SettingsInterfaceController {
    struct LocalizedString {
        static let CloseSettingsTitle =
        NSLocalizedString("2 - Close",
            comment: "Apple Watch App: SettingsInterfaceController: CloseSettingsTitle: This is the title of the Settings screen. The title doubles as the close the button."
        )
        static let SuggestedTipPercentageHeader =
        NSLocalizedString("1 - Suggested Tip Percentage",
            comment: "Apple Watch App: SettingsInterfaceController: SuggestedTipPercentageHeader: Header Text for a group of cells that allow choosing the default tip percentage."
        )
        static let CurrencySymbolHeader =
        NSLocalizedString("1 - Currency Symbol",
            comment: "Apple Watch App: SettingsInterfaceController: CurrencySymbolHeader: Header Text for a group of cells that allow choosing the currency symbol."
        )
        static let LocalCurrencyRowLabel =
        NSLocalizedString("Local",
            comment: "Apple Watch App: SettingsInterfaceController: LocalCurrencyRowLabel: Cell that tells the system to use the regional currency symbol."
        )
        static let NoneCurrencyRowLabel =
        NSLocalizedString("None",
            comment: "Apple Watch App: SettingsInterfaceController: NoneCurrencyRowLabel: Cell that tells the system to use no currency symbol."
        )
    }
}









