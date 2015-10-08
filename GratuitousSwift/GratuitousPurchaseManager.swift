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
    var price: Double { get }
    var skProductValue: SKProduct { get }
}

class GratuitousPurchaseManager: JSBPurchaseManager {
    
    static let Products = Set([SplitBillProduct.identifierString])
    
    override var Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El: String {
        let bytes: [CChar] = [0x63, 0x6f, 0x6d, 0x2e, 0x73, 0x61, 0x74, 0x75, 0x72, 0x64, 0x61, 0x79, 0x61, 0x70, 0x70, 0x73, 0x2e, 0x47, 0x72, 0x61, 0x74, 0x75, 0x69, 0x74, 0x79]
        return NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as! String
    }
    
    private(set) var splitBillProduct: SplitBillProduct? {
        didSet {
            self.productRequestCompletionHandlers.forEach() { completionHandler in
                completionHandler()
            }
            self.productRequestCompletionHandlers = []
        }
    }
    
    override init() {
        super.init()
        if self.verifySplitBillPurchaseTransaction() == false {
            self.requestSplitBillProductWithCompletionHandler(.None)
        }
    }
    
    private var productRequestCompletionHandlers = [ProductsRequestCompletionHandler]()
    private typealias ProductsRequestCompletionHandler = () -> Void

    func requestSplitBillProductWithCompletionHandler(completionHandler: (() -> Void)?) {
        if let completionHandler = completionHandler {
            self.productRequestCompletionHandlers += [completionHandler]
        }
        
        let request = SKProductsRequest(productIdentifiers: GratuitousPurchaseManager.Products)
        self.initiateRequest(request) { request, response, error in
            guard let response = response else { return }
            for product in response.products {
                if product.productIdentifier == SplitBillProduct.identifierString {
                    self.splitBillProduct = SplitBillProduct(product: product)
                    break
                }
            }
        }
    }
    
    func purchaseSplitBillProductWithCompletionHandler(completionHandler: (transaction: SKPaymentTransaction) -> ()) {
        let payment = SKPayment(product: self.splitBillProduct!.skProductValue)
        self.initiatePurchaseWithPayment(payment, completionHandler: completionHandler)
    }
    
    // MARK: Receipt Verification
    
    func verifySplitBillPurchaseTransaction() -> Bool {
        if let receipt = RMAppReceipt.bundleReceipt() where self.verifyAppReceiptAgainstAppleCertificate() == true {
            var verified = false
            for purchase in receipt.inAppPurchases {
                if purchase.productIdentifier == SplitBillProduct.identifierString {
                    verified = true
                    break
                }
            }
            return verified
        } else {
            return false
        }
    }
    
    struct SplitBillProduct: Purchasable {
        static let identifierString = "com.saturdayapps.gratuity.splitbillpurchase"
        let localizedTitle: String
        let localizedDescription: String
        let price: Double
        let skProductValue: SKProduct
        
        init(product: SKProduct) {
            self.localizedTitle = product.localizedTitle
            self.localizedDescription = product.localizedDescription
            self.price = product.price.doubleValue
            self.skProductValue = product
        }
        
        var description: String {
            return "SplitBillProduct: Price \(self.price), Title \(self.localizedTitle), Description \(self.localizedDescription)"
        }
    }
}

