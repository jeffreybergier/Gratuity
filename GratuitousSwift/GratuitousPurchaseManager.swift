//
//  GratuitousPurchaseManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import StoreKit

protocol Purchasable {
    static var identifierString: String { get }
    var purchased: Bool { get set }
}

class GratuitousPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    private(set) var splitBillProduct = SplitBillProduct(purchased: false)
    private lazy var paymentQueue: SKPaymentQueue = {
        let queue = SKPaymentQueue.defaultQueue()
        queue.addTransactionObserver(self)
        return queue
    }()
    
    init(requestImmediately: Bool) {
        super.init()
        if requestImmediately == true {
            self.requestProducts()
        }
    }
    
    private var latestRequest: SKProductsRequest?
    
    func requestProducts() {
        if let requestInProgress = self.latestRequest {
            requestInProgress.cancel()
            self.latestRequest = .None
        }
        
        self.latestRequest = SKProductsRequest(productIdentifiers: self.products)
        self.latestRequest?.delegate = self
        self.latestRequest?.start()
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if let latestRequest = self.latestRequest where request == latestRequest {
            print("GratuitousPurchaseManager: Valid Items: \(response.products)")
            print("GratuitousPurchaseManager: Invalid Items:  \(response.invalidProductIdentifiers)")
        }
        self.latestRequest = .None
    }
    
    private var latestRestoreCompletionHandler: ((queue: SKPaymentQueue, success: Bool, error: NSError?) -> ())?
    func restorePurchasesWithCompletionHandler(completionHandler: (queue: SKPaymentQueue, success: Bool, error: NSError?) -> ()) {
        if let existingCompletionHandler = self.latestRestoreCompletionHandler {
            existingCompletionHandler(queue: self.paymentQueue, success: false, error: NSError(domain: "SKErrorDomain", code: 23, userInfo: ["NSLocalizedDescription" : "Restore request interrupted by another restore request."]))
            self.latestRestoreCompletionHandler = .None
        }
        self.latestRestoreCompletionHandler = completionHandler
        self.paymentQueue.restoreCompletedTransactions()
    }
    
    // Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    // Sent when transactions are removed from the queue (via finishTransaction:).
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    // Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        self.latestRestoreCompletionHandler?(queue: queue, success: false, error: error)
        self.latestRestoreCompletionHandler = .None
    }
    
    // Sent when all transactions from the user's purchase history have successfully been added back to the queue.
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        self.latestRestoreCompletionHandler?(queue: queue, success: true, error: .None)
        self.latestRestoreCompletionHandler = .None
    }
    
    // Sent when the download state has changed.
    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        
    }
    
    let products = Set([
        SplitBillProduct.identifierString,
        "com.saturdayapps.gratuity.splitbillpurchase",
        "com.saturdayapps.Gratuity.splitbillpurchase2",
        "com.SaturdayApps.Gratuity.splitbillpurchase2",
        "splitbillpurchase2",
        "fakeItem"
        ])
    
    struct SplitBillProduct: Purchasable {
        static let identifierString = "com.saturdayapps.gratuity.splitbillpurchase2"
        var purchased = false
    }
}