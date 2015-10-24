//
//  PurchaseManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/30/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

class JSBPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    private let paymentQueue = SKPaymentQueue.defaultQueue()
    
    // MARK: Set Observer
    
    func beginObserving() {
        self.paymentQueue.addTransactionObserver(self)
    }
    
    func endObserving() {
        self.paymentQueue.removeTransactionObserver(self)
        for (key, _) in self.productsRequestsInProgress {
            key.cancel()
            key.delegate = .None
        }
        self.productsRequestsInProgress = [ : ]
        self.latestPurchasesRestoreCompletionHandler = .None
        self.purchasesInProgress = [ : ]
    }
    
    // MARK: Receipt verification
    
    var Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El: String {
        return "OBFUSCATE YOUR BUNDLE ID HERE"
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
    
    func restorePurchasesWithCompletionHandler(completionHandler: (queue: SKPaymentQueue?, error: NSError?) -> ()) {
        if let _ = self.latestPurchasesRestoreCompletionHandler {
            completionHandler(queue: .None, error: NSError(purchaseError: .RestorePurchasesAlreadyInProgress))
        } else {
            self.latestPurchasesRestoreCompletionHandler = completionHandler
            self.paymentQueue.restoreCompletedTransactions()
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        self.latestPurchasesRestoreCompletionHandler?(queue: queue, error: error)
        self.latestPurchasesRestoreCompletionHandler = .None
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        self.latestPurchasesRestoreCompletionHandler?(queue: queue, error: .None)
        self.latestPurchasesRestoreCompletionHandler = .None
    }
    
    private typealias PurchasesRestoreCompletionHandler = (queue: SKPaymentQueue?, error: NSError?) -> ()
    
    // MARK: Purchasing Items
    
    private var purchasesInProgress = [SKPayment : PurchasePaymentCompletionHandler]()
    
    private class BogusTransaction: SKPaymentTransaction {
        override var error: NSError? {
            get {
                return _error
            }
            set {
                _error = newValue
            }
        }
        private var _error: NSError?
    }
    
    func initiatePurchaseWithPayment(payment: SKPayment, completionHandler: (transaction: SKPaymentTransaction) -> ()) {
        if let existingCompletionHandler = self.purchasesInProgress[payment] {
            let bogusTransaction = BogusTransaction()
            bogusTransaction.error = NSError(purchaseError: .PurchaseAlreadyInProgress)
            existingCompletionHandler(transaction: bogusTransaction)
        } else {
            self.purchasesInProgress[payment] = completionHandler
            self.paymentQueue.addPayment(payment)
        }
    }
    
    // Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
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
