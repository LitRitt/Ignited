//
//  AppPresetOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/7/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

struct AppPresetOptions
{
    @Option(name: "Stock Preset",
            description: "Sets visual customization to the stock Ignited settings.",
            detailView: { _ in
        Button("Stock Preset") {
            AppPresetOptions.setStockPreset()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(Color.primary)
        .displayInline()
    })
    var stock: Bool = false
    
    @Option(name: "Theme Preset",
            description: "Sets visual customization to use the theme color where possible.",
            detailView: { _ in
        Button("Theme Preset") {
            AppPresetOptions.setThemePreset()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(Color(UIColor.themeColor))
        .displayInline()
    })
    var theme: Bool = false
    
    @Option(name: "Battery Preset",
            description: "Sets visual customization to use the battery color where possible.",
            detailView: { _ in
        Button("Battery Preset") {
            AppPresetOptions.setBatteryPreset()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(Color(UIColor.batteryColor))
        .displayInline()
    })
    var battery: Bool = false
}

extension AppPresetOptions
{
    static func setStockPreset()
    {
        Settings.standardSkinFeatures.styleAndColor.color = .auto
        Settings.controllerFeatures.backgroundBlur.tintColor = .none
        Settings.touchFeedbackFeatures.touchOverlay.color = .auto
        
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        ToastView.show(NSLocalizedString("Stock Preset Applied", comment: ""), in: topViewController.view, onEdge: .bottom, duration: 3.0)
    }
    
    static func setThemePreset()
    {
        Settings.standardSkinFeatures.styleAndColor.color = .theme
        Settings.controllerFeatures.backgroundBlur.tintColor = .theme
        Settings.touchFeedbackFeatures.touchOverlay.color = .theme
        
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        ToastView.show(NSLocalizedString("Theme Preset Applied", comment: ""), in: topViewController.view, onEdge: .bottom, duration: 3.0)
    }
    
    static func setBatteryPreset()
    {
        Settings.standardSkinFeatures.styleAndColor.color = .battery
        Settings.controllerFeatures.backgroundBlur.tintColor = .battery
        Settings.touchFeedbackFeatures.touchOverlay.color = .battery
        
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        ToastView.show(NSLocalizedString("Battery Preset Applied", comment: ""), in: topViewController.view, onEdge: .bottom, duration: 3.0)
    }
}
