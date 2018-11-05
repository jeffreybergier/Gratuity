//
//  GratuitousPurchaseManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

final class GratuitousPurchaseManager: JSBPurchaseManager {

    static let splitBillPurchaseIdentifier = "com.saturdayapps.gratuity.splitbillpurchase"
    
    override var Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El: String {
        let bytes: [CChar] = [0x63, 0x6f, 0x6d, 0x2e, 0x73, 0x61, 0x74, 0x75, 0x72, 0x64, 0x61, 0x79, 0x61, 0x70, 0x70, 0x73, 0x2e, 0x47, 0x72, 0x61, 0x74, 0x75, 0x69, 0x74, 0x79]
        return (NSString(bytes: bytes, length: bytes.count, encoding: String.Encoding.utf8.rawValue) as String?)!
    }
    
    // MARK: Receipt Verification
    
    func splitBillPurchaseData() -> Date? {
        if let receipt = self.splitBillReceipt() {
            return receipt.purchaseDate
        }
        return .none
    }
    
    func splitBillReceipt() -> RMAppReceiptIAP? {
        guard
            let receipt = RMAppReceipt.bundle(),
            let purchases = receipt.inAppPurchases,
            self.verifyAppReceiptAgainstAppleCertificate() == true
        else { return nil }
        for purchase in purchases {
            if purchase.productIdentifier == GratuitousPurchaseManager.splitBillPurchaseIdentifier {
                return purchase
            }
        }
        return nil
    }

    func verifySplitBillPurchaseTransaction() -> Bool {
        if let _ = self.splitBillReceipt() {
            return true
        } else {
            return false
        }
    }
}

