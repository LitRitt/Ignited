//
//  PurchaseManager.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/6/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import StoreKit

extension PurchaseManager
{
    static let purchasesUpdatedNotification: Notification.Name = Notification.Name("PurchaseManager.purchasesUpdatedNotification")
}

public enum PurchaseType: String, CaseIterable
{
    case monthly = "IgnitedPro"
    case yearly = "IgnitedProYearly"
    case lifetime = "IgnitedProLifetime"
    
    var productID: String
    {
        return self.rawValue
    }
    
    var description: String
    {
        switch self
        {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }
    
    var available: Bool
    {
        let purchasedIDs = PurchaseManager.shared.purchasedProductIDs
        
        let purchasedMonthly = purchasedIDs.contains(PurchaseType.monthly.productID)
        let purchasedYearly = purchasedIDs.contains(PurchaseType.yearly.productID)
        let purchasedLifetime = purchasedIDs.contains(PurchaseType.lifetime.productID)
        
        switch self
        {
        case .monthly: return !purchasedMonthly && !purchasedYearly && !purchasedLifetime
        case .yearly: return !purchasedYearly && !purchasedLifetime
        case .lifetime: return !purchasedLifetime
        }
    }
}

extension PurchaseManager
{
    static var benefits: [String]
    {[
        "More hand-crafted icons to customize your home screen",
        "Custom color option for themes, UI, and skins",
        "Dynamic color option that adjusts to your device's battery level",
        "Customizable styles for game artwork",
        "2 customizable buttons for standard skins",
        "2 more custom gameboy palette slots and more preset palettes",
        "More game background blur styles and background blur support for AirPlay displays",
        "More rewind states and shorter rewind intervals",
        "Use your most recent auto save state preview as game artwork"
    ]}
}

class PurchaseManager: ObservableObject
{
    static let shared = PurchaseManager()
    
    private let productIds = PurchaseType.allCases.map { $0.productID }
    
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
        guard !self.purchasedProductIDs.contains(PurchaseType.lifetime.productID) else { return }
        
        Task
        {
            let result = try await product.purchase()
            
            switch result
            {
            case let .success(.verified(transaction)):
                await transaction.finish()
                self.updatePurchasedProducts()
                
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
            
            self.updateProFeatures()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PurchaseManager.purchasesUpdatedNotification, object: nil)
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never>
    {
        Task(priority: .background)
        { [unowned self] in
            for await verificationResult in Transaction.updates
            {
                self.updatePurchasedProducts()
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
    
    func updateProFeatures()
    {
        // Reset all Pro settings if user isn't a Pro member
        if !self.hasUnlockedPro
        {
            // Standard Skin Style
            Settings.standardSkinFeatures.styleAndColor.style = .filled
            if Settings.standardSkinFeatures.styleAndColor.color.pro {
                Settings.standardSkinFeatures.styleAndColor.color = .auto
            }
            //Standard Skin Layout
            Settings.standardSkinFeatures.inputsAndLayout.customButton1 = .null
            Settings.standardSkinFeatures.inputsAndLayout.customButton2 = .null
            Settings.standardSkinFeatures.inputsAndLayout.dsScreenSwap = false
            // Background Blur
            Settings.controllerFeatures.backgroundBlur.style = .systemThin
            if Settings.controllerFeatures.backgroundBlur.tintColor.pro {
                Settings.controllerFeatures.backgroundBlur.tintColor = .none
            }
            // AirPlay
            Settings.airplayFeatures.display.backgroundBlur = false
            // Live artwork
            Settings.libraryFeatures.artwork.useScreenshots = false
            // Rewind
            Settings.gameplayFeatures.rewind.keepStates = false
            Settings.gameplayFeatures.rewind.maxStates = 4
            Settings.gameplayFeatures.rewind.interval = 15
            // Touch overlay
            if Settings.touchFeedbackFeatures.touchOverlay.color.pro {
                Settings.touchFeedbackFeatures.touchOverlay.color = .theme
            }
            // Skin color
            if Settings.controllerFeatures.skin.colorMode == .custom {
                Settings.controllerFeatures.skin.colorMode = .none
            }
            // Artwork
            if Settings.libraryFeatures.artwork.style == .custom {
                Settings.libraryFeatures.artwork.style = .basic
            }
            if Settings.libraryFeatures.favorites.style == .custom {
                Settings.libraryFeatures.favorites.style = .theme
            }
            // Theme color
            if Settings.userInterfaceFeatures.theme.color == .custom {
                Settings.userInterfaceFeatures.theme.color = .orange
            }
            // Palettes
            if Settings.gbFeatures.palettes.palette.pro {
                Settings.gbFeatures.palettes.palette = .studio
            }
            if Settings.gbFeatures.palettes.spritePalette1.pro {
                Settings.gbFeatures.palettes.spritePalette1 = .studio
            }
            if Settings.gbFeatures.palettes.spritePalette2.pro {
                Settings.gbFeatures.palettes.spritePalette2 = .studio
            }
            // App icon
            if Settings.userInterfaceFeatures.appIcon.alternateIcon.pro {
                Settings.userInterfaceFeatures.appIcon.alternateIcon = .normal
            }
            AppIconOptions.updateAppIcon()
        }
    }
}
