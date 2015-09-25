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

class GratuitousPurchaseManager: NSObject, SKProductsRequestDelegate {
    
    private(set) var splitBillProduct = SplitBillProduct(purchased: false)
    
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
    
    let products = Set([
        SplitBillProduct.identifierString,
        "com.saturdayapps.Gratuity.splitbillpurchase",
        "com.SaturdayApps.Gratuity.splitbillpurchase",
        "splitbillpurchase",
        "fakeItem"
        ])
    
    struct SplitBillProduct: Purchasable {
        static let identifierString = "com.saturdayapps.gratuity.splitbillpurchase"
        var purchased = false
    }
}