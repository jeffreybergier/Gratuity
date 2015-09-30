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
    var purchased: Bool? { get set }
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var price: Double { get }
    var skProductValue: SKProduct { get }
}

class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var paymentQueue: SKPaymentQueue { return SKPaymentQueue.defaultQueue() }
    private var transactionObserverSet = false
    
    // MARK: Product Request
    
    private var productsRequestsInProgress = [SKRequest : ProductsRequestCompletionHandler]()
    
    func initiateRequest(request: SKProductsRequest, completionHandler: (request: SKProductsRequest, response: SKProductsResponse?, error: NSError?) -> ()) {
        self.productsRequestsInProgress[request] = completionHandler
        request.delegate = self
        request.start()
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if let completionHandler = self.productsRequestsInProgress[request] {
            completionHandler(request: request, response: response, error: .None)
        }
        self.productsRequestsInProgress.removeValueForKey(request)
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        if let completionHandler = self.productsRequestsInProgress[request], let productsRequest = request as? SKProductsRequest {
            completionHandler(request: productsRequest, response: .None, error: error)
        }
        self.productsRequestsInProgress.removeValueForKey(request)
    }
    
    private typealias ProductsRequestCompletionHandler = (request: SKProductsRequest, response: SKProductsResponse?, error: NSError?) -> ()
    
    // MARK: Restore Purchases
    
    private var latestPurchasesRestoreCompletionHandler: PurchasesRestoreCompletionHandler?
    
    func restorePurchasesWithCompletionHandler(completionHandler: (queue: SKPaymentQueue?, success: Bool, error: NSError?) -> ()) {
        if self.transactionObserverSet == true {
            if let _ = self.latestPurchasesRestoreCompletionHandler {
                completionHandler(queue: .None, success: false, error: NSError(domain: "SKErrorDomain", code: 27, userInfo: ["NSLocalizedDescription" : "Purchase Restore already in progress. Wait for the previous one to succeed or fail and then try again."]))
            } else {
                self.latestPurchasesRestoreCompletionHandler = completionHandler
                self.paymentQueue.restoreCompletedTransactions()
            }
        } else {
            completionHandler(queue: .None, success: false, error: NSError(domain: "SKErrorDomain", code: 26, userInfo: ["NSLocalizedDescription" : "Purchase Queue Observer Not Set. This is usually due to products never having been downloaded. Perform Products Request, then try again."]))
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        self.latestPurchasesRestoreCompletionHandler?(queue: queue, success: false, error: error)
        self.latestPurchasesRestoreCompletionHandler = .None
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        self.latestPurchasesRestoreCompletionHandler?(queue: queue, success: true, error: .None)
        self.latestPurchasesRestoreCompletionHandler = .None
    }
    
    private typealias PurchasesRestoreCompletionHandler = (queue: SKPaymentQueue?, success: Bool, error: NSError?) -> ()
    
    // MARK: Purchasing Items
    
    private var latestPurchaseCompletionHandler: ((purchasable: Purchasable, transaction: SKPaymentTransaction?, error: NSError?) -> ())?
    private var latestPurchasePayment: SKPayment?
    private var latestPurchasePurchasable: Purchasable?
    func buyPurchasable(purchasable: Purchasable, completionHandler: (purchasable: Purchasable, transaction: SKPaymentTransaction?, error: NSError?) -> ()) {
        if let existingCompletionHandler = self.latestPurchaseCompletionHandler {
            existingCompletionHandler(purchasable: self.latestPurchasePurchasable!, transaction: .None, error: NSError(domain: "SKErrorDomain", code: 25, userInfo: ["NSLocalizedDescription" : "Purchase request interrupted by another purchase request."]))
            self.latestPurchaseCompletionHandler = .None
            self.latestPurchasePayment = .None
            self.latestPurchasePurchasable = .None
        }
        
        let payment = SKPayment(product: purchasable.skProductValue)
        self.latestPurchaseCompletionHandler = completionHandler
        self.latestPurchasePayment = payment
        self.latestPurchasePurchasable = purchasable
        self.paymentQueue.addPayment(payment)
    }
    
    // Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}


class GratuitousPurchaseManager: PurchaseManager {
    
    static let Products = Set([SplitBillProduct.identifierString])
    
    private(set) var splitBillProduct: SplitBillProduct? {
        didSet {
            struct Token {
                static var onceToken: dispatch_once_t = 0
            }
            dispatch_once(&Token.onceToken) {
                self.paymentQueue.addTransactionObserver(self)
                self.transactionObserverSet = true
            }
        }
    }
    
    init(requestAvailableProductsImmediately: Bool) {
        super.init()
        if requestAvailableProductsImmediately == true {
            self.requestProducts()
        }
    }

    func requestProducts() {
        let request = SKProductsRequest(productIdentifiers: GratuitousPurchaseManager.Products)
        self.initiateRequest(request) { request, response, error in
            guard let response = response else {
                NSLog("GratuitousPurchaseManager: Product Request at Init Failed. Be Sure to Request Products Again before Attempting to Restore or Initiate Purchases: \(error)")
                return
            }
            
            for product in response.products {
                if product.productIdentifier == SplitBillProduct.identifierString {
                    self.splitBillProduct = SplitBillProduct(product: product)
                    break
                }
            }
        }
    }
    
    struct SplitBillProduct: Purchasable {
        static let identifierString = "com.saturdayapps.gratuity.splitbillpurchase"
        var purchased: Bool?
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
            return "SplitBillProduct: Price \(self.price), Purchased \(self.purchased), Title \(self.localizedTitle), Description \(self.localizedDescription)"
        }
    }
}

