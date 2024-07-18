//
//  OnboardingView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/31/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import UIKit
import SwiftUI
import Features

struct OnboardingView: View {
    
    @ObservedObject
    private var purchaseManager = PurchaseManager.shared
    
    @State
    private var themeColor: ThemeColor = Settings.userInterfaceFeatures.theme.color
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Image("Flame")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(Color.accentColor)
                .blur(radius: 30)
                .opacity(0.2)
                .frame(maxWidth: 500)
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Image(systemName: "chevron.down")
                    Text("Swipe down to dismiss")
                    Image(systemName: "chevron.down")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
                
                ZStack(alignment: .center) {
                    Color.accentColor
                    Image("Flame")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .padding(.all, 10)
                        .shadow(radius: 2)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(50)
                .padding(.vertical, 12)
                .shadow(color: .accentColor, radius: 30)
                
                Text("Welcome to Ignited")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Where retro games meet modern design")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("""
Ignited aims to be a customizable and user friendly emulator, supporting an open and creative community. To access more themes, icons, settings, and to support development of Ignited, consider becoming a Pro member. You can become a Pro member by joining my Patreon. Go to settings for more info.

Start customizing your experience by choosing a theme color below. Once you're finished, swipe down to dismiss this message and start adding your games.
""")
                    .font(.caption)
                    .padding(.vertical, 6)
//                HStack(spacing: 16) {
//                    ForEach(purchaseManager.products, id: \.self) { product in
//                        Button(action: {
//                            purchaseManager.purchase(product)
//                        }, label: {
//                            VStack {
//                                Text(PurchaseType(rawValue: product.id)?.description ?? "Pro")
//                                    .font(.system(size: 20, weight: .semibold))
//                                Text(product.displayPrice)
//                                    .font(.caption)
//                            }
//                            .padding(10)
//                        }).disabled(!(PurchaseType(rawValue: product.id)?.available ?? true))
//                            .background(
//                                Color(uiColor: .systemBackground).opacity(0.2)
//                                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                            )
//                    }
//                }
                
//                Text("Start customizing your experience by choosing a theme color below. Once you're finished, swipe down to dismiss this message and start adding your games.")
//                    .font(.caption)
//                    .padding(.vertical, 6)
                
                Picker("Theme Color", selection: self.$themeColor) {
                    ForEach(ThemeColor.allCases.filter { !$0.pro }, id: \.self) { color in
                        color.localizedDescription
                    }
                }.pickerStyle(.inline)
                    .onChange(of: self.themeColor) { value in
                        Settings.userInterfaceFeatures.theme.color = value
                    }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 500)
        }
        .background(.ultraThinMaterial)
        .onDisappear {
            Settings.onboardingHasBeenCompleted = true
        }
    }
}

extension OnboardingView
{
    static func makeViewController() -> UIHostingController<some View>
    {
        let onboardingView = OnboardingView()
        
        let hostingController = UIHostingController(rootView: onboardingView)
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
}
