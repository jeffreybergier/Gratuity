//
//  GratuitousPurchaseManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import StoreKit

protocol Purchasable: CustomStringConvertible {
    static var identifierString: String { get }
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var price: NSDecimalNumber { get }
    var priceLocale: NSLocale { get }
    var skProductValue: SKProduct { get }
}

final class GratuitousPurchaseManager: JSBPurchaseManager {
    
    override var Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El: String {
        let bytes: [CChar] = [0x63, 0x6f, 0x6d, 0x2e, 0x73, 0x61, 0x74, 0x75, 0x72, 0x64, 0x61, 0x79, 0x61, 0x70, 0x70, 0x73, 0x2e, 0x47, 0x72, 0x61, 0x74, 0x75, 0x69, 0x74, 0x79]
        return NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as! String
    }
    
    // MARK: Receipt Verification
    
    func verifySplitBillPurchaseTransaction() -> Bool {
        if let receipt = RMAppReceipt.bundleReceipt() where self.verifyAppReceiptAgainstAppleCertificate() == true {
            var verified = false
            for purchase in receipt.inAppPurchases {
                if purchase.productIdentifier == GratuitousPurchaseManager.splitBillPurchaseIdentifier {
                    verified = true
                    break
                }
            }
            return verified
        } else {
            return false
        }
    }
    
    static let splitBillPurchaseIdentifier = "com.saturdayapps.gratuity.splitbillpurchase"
}

