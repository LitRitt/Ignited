//
//  PurchaseManager.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/6/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import StoreKit

class PurchaseManager: ObservableObject
{
    static let shared = PurchaseManager()
    
    private let productIds = ["IgnitedPro", "IgnitedProYearly", "IgnitedProLifetime"]
    
    @Published
    private(set) var products: [Product] = []
    private var productsLoaded = false
    
    @Published
    private(set) var purchasedProductIDs = Set<String>()
    
    private var updates: Task<Void, Never>? = nil
    
    init()
    {
        self.updates = observeTransactionUpdates()
    }
    
    deinit {
        self.updates?.cancel()
    }
    
    func loadProducts()
    {
        guard !self.productsLoaded else { return }
        
        Task
        {
            self.products = try await Product.products(for: productIds).sorted(by: { (lhs, rhs) in
                lhs.price < rhs.price
            })
            self.productsLoaded = true
        }
    }
    
    func purchase(_ product: Product)
    {
        Task
        {
            let result = try await product.purchase()
            
            switch result
            {
            case let .success(.verified(transaction)):
                await transaction.finish()
                await self.updatePurchasedProducts()
                
            case let .success(.unverified(_, error)): break
            case .pending: break
            case .userCancelled: break
            @unknown default: break
            }
        }
    }
    
    var hasUnlockedPro: Bool
    {
        return !self.purchasedProductIDs.isEmpty
    }
    
    func updatePurchasedProducts()
    {
        Task
        {
            for await result in Transaction.currentEntitlements
            {
                guard case .verified(let transaction) = result else { continue }
                
                if transaction.revocationDate == nil
                {
                    self.purchasedProductIDs.insert(transaction.productID)
                }
                else
                {
                    self.purchasedProductIDs.remove(transaction.productID)
                }
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never>
    {
        Task(priority: .background)
        { [unowned self] in
            for await verificationResult in Transaction.updates
            {
                await self.updatePurchasedProducts()
            }
        }
    }
    
    func restorePurchases()
    {
        Task
        {
            do
            {
                try await AppStore.sync()
            }
            catch
            {
                print(error)
            }
        }
    }
}
