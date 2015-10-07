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
    
    // MARK: Receipt verification
    
    var Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El: String {
        //let bytes: [CChar] = [0x63, 0x6f, 0x6d, 0x2e, 0x73, 0x61, 0x74, 0x75, 0x72, 0x64, 0x61, 0x79, 0x61, 0x70, 0x70, 0x73, 0x2e, 0x47, 0x72, 0x61, 0x74, 0x75, 0x69, 0x74, 0x79]
        return "OBFUSCATE YOUR BUNDLE ID HERE"//NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as! String
    }
    
    func verifyAppReceiptAgainstAppleCertificate() -> Bool {
        let verifier = RMStoreAppReceiptVerifier()
        verifier.bundleIdentifier = Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El
        let verified = verifier.verifyAppReceipt()
        return verified
    }
    
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
                completionHandler(queue: .None, success: false, error: NSError(purchaseError: .RestorePurchasesAlreadyInProgress))
            } else {
                self.latestPurchasesRestoreCompletionHandler = completionHandler
                self.paymentQueue.restoreCompletedTransactions()
            }
        } else {
            completionHandler(queue: .None, success: false, error: NSError(purchaseError: .ProductRequestNeeded))
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
            case .Purchasing:
                break // do nothing and wait
            case .Purchased, .Restored, .Failed, .Deferred:
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
    
    func finishTransaction(transaction: SKPaymentTransaction) {
        self.paymentQueue.finishTransaction(transaction)
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
