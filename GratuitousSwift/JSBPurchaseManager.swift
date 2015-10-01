//
//  PurchaseManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/30/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import StoreKit

class JSBPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var paymentQueue: SKPaymentQueue { return SKPaymentQueue.defaultQueue() }
    var transactionObserverSet = false
    
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
    
    private var purchasesInProgress = [SKPayment : PurchasePaymentCompletionHandler]()
    
    func initiatePurchaseWithPayment(payment: SKPayment, completionHandler: (transaction: SKPaymentTransaction) -> ()) {
        if let _ = self.purchasesInProgress[payment] {
            // return error about payment is already in progress
        } else {
            self.purchasesInProgress[payment] = completionHandler
            self.paymentQueue.addPayment(payment)
        }
    }
    
    // Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("PurchaseManager: Transaction: \(transaction) changed to state \(transaction.transactionState) with error: \(transaction.error)")
            switch transaction.transactionState {
            case .Purchasing, .Deferred:
                break // do nothing and wait
            case .Purchased, .Restored, .Failed:
                if let completionHandler = self.purchasesInProgress[transaction.payment] {
                    completionHandler(transaction: transaction)
                    self.purchasesInProgress.removeValueForKey(transaction.payment)
                } else {
                    // we know finish can never get called on these transactions because there is no completion handler
                    // doing it now in a last ditch effort to prevent errors
                    queue.finishTransaction(transaction)
                }
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("PurchaseManager: Transaction: \(transaction) in state \(transaction.transactionState) Removed from Queue with error: \(transaction.error)")
        }
    }
    
    private typealias PurchasePaymentCompletionHandler = (transaction: SKPaymentTransaction) -> ()
}

extension SKPaymentTransactionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Deferred:
            return "SKPaymentTransactionState.Deferred"
        case .Failed:
            return "SKPaymentTransactionState.Failed"
        case .Purchased:
            return "SKPaymentTransactionState.Purchased"
        case .Purchasing:
            return "SKPaymentTransactionState.Purchasing"
        case .Restored:
            return "SKPaymentTransactionState.Restored"
        }
    }
}
