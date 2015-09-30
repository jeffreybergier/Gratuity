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
    
    private lazy var paymentQueue: SKPaymentQueue = {
        let queue = SKPaymentQueue.defaultQueue()
        queue.addTransactionObserver(self)
        return queue
    }()
    
    private var latestProductRequestCompletionHandler: ((request: SKProductsRequest?, response: SKProductsResponse?, error: NSError?) -> ())?
    private var latestProductRequest: SKProductsRequest?
    func initiateRequest(request: SKProductsRequest, completionHandler: (request: SKProductsRequest?, response: SKProductsResponse?, error: NSError?) -> ()) {
        if let existingCompletionHandler = self.latestProductRequestCompletionHandler {
            self.latestProductRequest?.cancel()
            existingCompletionHandler(request: self.latestProductRequest, response: .None, error: NSError(domain: "SKErrorDomain", code: 24, userInfo: ["NSLocalizedDescription" : "Product request interupted by another restore request."]))
            self.latestProductRequest = .None
            self.latestProductRequestCompletionHandler = .None
        }
        self.latestProductRequest = request
        self.latestProductRequestCompletionHandler = completionHandler
        request.delegate = self
        request.start()
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        self.latestProductRequestCompletionHandler?(request: request, response: response, error: .None)
    }
    
    // MARK: Restore Purchases
    
    private var latestRestoreCompletionHandler: ((queue: SKPaymentQueue, success: Bool, error: NSError?) -> ())?
    func restorePurchasesWithCompletionHandler(completionHandler: (queue: SKPaymentQueue, success: Bool, error: NSError?) -> ()) {
        if let existingCompletionHandler = self.latestRestoreCompletionHandler {
            existingCompletionHandler(queue: self.paymentQueue, success: false, error: NSError(domain: "SKErrorDomain", code: 23, userInfo: ["NSLocalizedDescription" : "Restore request interrupted by another restore request."]))
            self.latestRestoreCompletionHandler = .None
        }
        self.latestRestoreCompletionHandler = completionHandler
        self.paymentQueue.restoreCompletedTransactions()
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        self.latestRestoreCompletionHandler?(queue: queue, success: false, error: error)
        self.latestRestoreCompletionHandler = .None
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        self.latestRestoreCompletionHandler?(queue: queue, success: true, error: .None)
        self.latestRestoreCompletionHandler = .None
    }
    
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
        if queue == self.paymentQueue {
            for transaction in transactions {
                if transaction.payment == self.latestPurchasePayment {
                    switch transaction.transactionState {
                    case .Purchased, .Restored:
                        self.latestPurchaseCompletionHandler?(purchasable: self.latestPurchasePurchasable!, transaction: transaction, error: .None)
                        self.latestPurchaseCompletionHandler = .None
                        self.latestPurchasePayment = .None
                        self.latestPurchasePurchasable = .None
                    case .Failed, .Deferred:
                        self.latestPurchaseCompletionHandler?(purchasable: self.latestPurchasePurchasable!, transaction: transaction, error: transaction.error ?? NSError(domain: "SKErrorDomain", code: 26, userInfo: ["NSLocalizedDescription" : "Purchase Failed or Was Deferred"]))
                        self.latestPurchaseCompletionHandler = .None
                        self.latestPurchasePayment = .None
                        self.latestPurchasePurchasable = .None
                    default:
                        break
                    }
                }
            }
        } else {
            NSLog("PurchaseManager: Purchase transaction updated on unknown queue.")
        }
    }
}

class GratuitousPurchaseManager: PurchaseManager {
    private(set) var splitBillProduct: SplitBillProduct? {
        didSet {
            print("DidSet Product: \(self.splitBillProduct)")
        }
    }
    private let products = Set([SplitBillProduct.identifierString])
    
//    init(requestImmediately: Bool) {
//        super.init()
//        if requestImmediately == true {
//            self.requestProducts()
//        }
//    }
//    
//    func requestProducts() {
//        let request = SKProductsRequest(productIdentifiers: self.products)
//        self.latestRequest?.delegate = self
//        self.latestRequest?.start()
//    }
    
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

