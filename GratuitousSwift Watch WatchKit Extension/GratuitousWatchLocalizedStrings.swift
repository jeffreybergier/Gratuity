//
//  GratuitousWatchLocalizedStrings.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

extension SplitTotalInterfaceController {
    struct LocalizedString {
        static let TitleLabel =
        NSLocalizedString("Split Bill",
            comment: "Apple Watch App: SplitTotalInterfaceController: TitleLabel: Title for Split Bill Feature."
        )
    }
}

extension PickerInterfaceController {
    struct LocalizedString {
        static let SplitTipMenuIconLabel =
        NSLocalizedString("Split Bill",
            comment: "Apple Watch App: PickerInterfaceController: SplitTipMenuIconLabel: Text for the menu item that opens the split tip feature."
        )
        static let SettingsMenuIconLabel =
        NSLocalizedString("Settings",
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
    }
}

extension SettingsInterfaceController {
    struct LocalizedString {
        static let CloseSettingsTitle =
        NSLocalizedString("Close",
            comment: "Apple Watch App: SettingsInterfaceController: CloseSettingsTitle: This is the title of the Settings screen. The title doubles as the close the button."
        )
        static let SuggestedTipPercentageHeader =
        NSLocalizedString("Suggested Tip Percentage",
            comment: "Apple Watch App: SettingsInterfaceController: SuggestedTipPercentageHeader: Header Text for a group of cells that allow choosing the default tip percentage."
        )
        static let CurrencySymbolHeader =
        NSLocalizedString("Currency Symbol",
            comment: "Apple Watch App: SettingsInterfaceController: CurrencySymbolHeader: Header Text for a group of cells that allow choosing the currency symbol."
        )
        static let LocalCurrencyRowLabel =
        NSLocalizedString("Local Currency",
            comment: "Apple Watch App: SettingsInterfaceController: LocalCurrencyRowLabel: Cell that tells the system to use the regional currency symbol."
        )
        static let NoneCurrencyRowLabel =
        NSLocalizedString("No Symbol",
            comment: "Apple Watch App: SettingsInterfaceController: NoneCurrencyRowLabel: Cell that tells the system to use no currency symbol."
        )
    }
}









