//
//  PurchaseView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/20/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

struct PurchaseView: View {
    
    @ObservedObject
    private var purchaseManager = PurchaseManager.shared
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("LitRitt")
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(30)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("LitRitt")
                    .font(.system(size: 24, weight: .semibold))
                Text("Developer")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.all, 16)
        
        HStack(spacing: 16) {
            ForEach(purchaseManager.products, id: \.self) { product in
                Button(action: {
                    purchaseManager.purchase(product)
                }, label: {
                    VStack {
                        Text(PurchaseTypes(rawValue: product.id)?.description ?? "Pro")
                            .font(.system(size: 24, weight: .semibold))
                        Text(product.displayPrice)
                            .font(.caption)
                    }
                }).buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 8)
        
        List {
            Section {
                if purchaseManager.hasUnlockedPro {
                    Text("Thanks for joining Ignited Pro! ❤️‍🔥\n\nYou now have access to the Pro features of Ignited.\n\nYour support means the world to me, and helps me support my family. I hope I can keep making Ignited better and that it will continue to be worth your investment.").font(.caption)
                } else {
                    Text("Thanks for using Ignited! 🔥\n\nIf you'd like to support me and the development of this app, consider becoming a pro member.").font(.caption)
                }
            }
            
            Section(header: Text("Pro Benefits")) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(PurchaseManager.benefits, id: \.self) { benefit in
                        HStack {
                            Text("• " + benefit)
                                .foregroundStyle(.secondary)
                        }
                        .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
        }
    }
}

extension PurchaseView
{
    static func makeViewController() -> UIHostingController<some View>
    {
        let purchaseView = PurchaseView()
        
        let hostingController = UIHostingController(rootView: purchaseView)
        hostingController.title = NSLocalizedString("Ignited Pro", comment: "")
        return hostingController
    }
}
