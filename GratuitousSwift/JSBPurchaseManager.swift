//
//  PurchaseManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/30/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import StoreKit
import UIKit

class JSBPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    fileprivate let paymentQueue = SKPaymentQueue.default()
    
    // MARK: Set Observer
    
    func beginObserving() {
        self.paymentQueue.add(self)
    }
    
    func endObserving() {
        self.paymentQueue.remove(self)
        for (key, _) in self.productsRequestsInProgress {
            key.cancel()
            key.delegate = .none
        }
        self.productsRequestsInProgress = [ : ]
        self.latestPurchasesRestoreCompletionHandler = .none
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
    
    fileprivate var productsRequestsInProgress = [SKRequest : ProductsRequestCompletionHandler]()
    
    func initiateRequest(_ request: SKProductsRequest, completionHandler: @escaping (_ request: SKProductsRequest, _ response: SKProductsResponse?, _ error: NSError?) -> ()) {
        self.productsRequestsInProgress[request] = completionHandler
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let completionHandler = self.productsRequestsInProgress[request] {
            completionHandler(request, response, .none)
        }
        self.productsRequestsInProgress.removeValue(forKey: request)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if let completionHandler = self.productsRequestsInProgress[request], let productsRequest = request as? SKProductsRequest {
            completionHandler(productsRequest, .none, error as NSError)
        }
        self.productsRequestsInProgress.removeValue(forKey: request)
    }
    
    fileprivate typealias ProductsRequestCompletionHandler = (_ request: SKProductsRequest, _ response: SKProductsResponse?, _ error: NSError?) -> ()
    
    // MARK: Restore Purchases
    
    fileprivate var latestPurchasesRestoreCompletionHandler: PurchasesRestoreCompletionHandler?
    
    func restorePurchasesWithCompletionHandler(_ completionHandler: @escaping (_ queue: SKPaymentQueue?, _ error: NSError?) -> ()) {
        if let _ = self.latestPurchasesRestoreCompletionHandler {
            completionHandler(.none, NSError(purchaseError: .restorePurchasesAlreadyInProgress))
        } else {
            self.latestPurchasesRestoreCompletionHandler = completionHandler
            self.paymentQueue.restoreCompletedTransactions()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.latestPurchasesRestoreCompletionHandler?(queue, error as NSError)
        self.latestPurchasesRestoreCompletionHandler = .none
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.latestPurchasesRestoreCompletionHandler?(queue, .none)
        self.latestPurchasesRestoreCompletionHandler = .none
    }
    
    fileprivate typealias PurchasesRestoreCompletionHandler = (_ queue: SKPaymentQueue?, _ error: NSError?) -> ()
    
    // MARK: Purchasing Items
    
    fileprivate var purchasesInProgress = [SKPayment : PurchasePaymentCompletionHandler]()
    
    fileprivate class BogusTransaction: SKPaymentTransaction {
        override var error: Error? {
            get {
                return _error
            }
            set {
                _error = newValue
            }
        }
        fileprivate var _error: Error?
    }
    
    func initiatePurchaseWithPayment(_ payment: SKPayment, completionHandler: @escaping (_ transaction: SKPaymentTransaction) -> ()) {
        if let existingCompletionHandler = self.purchasesInProgress[payment] {
            let bogusTransaction = BogusTransaction()
            bogusTransaction.error = NSError(purchaseError: .purchaseAlreadyInProgress)
            existingCompletionHandler(bogusTransaction)
        } else {
            self.purchasesInProgress[payment] = completionHandler
            self.paymentQueue.add(payment)
        }
    }
    
    // Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break // do nothing and wait
            case .purchased, .restored, .failed, .deferred:
                if let completionHandler = self.purchasesInProgress[transaction.payment] {
                    completionHandler(transaction)
                    self.purchasesInProgress.removeValue(forKey: transaction.payment)
                } else {
                    // we know finish can never get called on these transactions because there is no completion handler
                    // doing it now in a last ditch effort to prevent errors
                    queue.finishTransaction(transaction)
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        self.paymentQueue.finishTransaction(transaction)
    }
    
    fileprivate typealias PurchasePaymentCompletionHandler = (_ transaction: SKPaymentTransaction) -> ()
}

extension SKPaymentTransactionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .deferred:
            return "SKPaymentTransactionState.Deferred"
        case .failed:
            return "SKPaymentTransactionState.Failed"
        case .purchased:
            return "SKPaymentTransactionState.Purchased"
        case .purchasing:
            return "SKPaymentTransactionState.Purchasing"
        case .restored:
            return "SKPaymentTransactionState.Restored"
        }
    }
}
