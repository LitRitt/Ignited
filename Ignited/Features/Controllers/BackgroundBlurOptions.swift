//
//  BackgroundBlurOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 6/28/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum BackgroundBlurTintColor: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case none = "None"
    case theme = "Theme"
    case battery = "Battery"
    case custom = "Custom"
    
    var description: String {
        return rawValue
    }
    
    var localizedDescription: Text {
        Text(description)
    }
    
    var uiColor: UIColor {
        switch self
        {
        case .none: return UIColor.clear
        case .theme: return UIColor.themeColor
        case .battery: return UIColor.batteryColor
        case .custom: return UIColor(Settings.controllerFeatures.backgroundBlur.customColor)
        }
    }
    
    var pro: Bool {
        switch self
        {
        case .battery, .custom: return true
        default: return false
        }
    }
}

enum BackgroundBlurBrightness: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case auto = "Auto"
    case light = "Light"
    case dark = "Dark"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum BackgroundBlurStyle: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case system = "System"
    case systemThin = "Thin"
    case systemUltraThin = "Ultra Thin"
    case systemThick = "Thick"
    case regular = "Regular"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
    
    var blurStyle: UIBlurEffect.Style
    {
        switch (self, Settings.controllerFeatures.backgroundBlur.brightness)
        {
        case (.system, .auto): return .systemMaterial
        case (.system, .light): return .systemMaterialLight
        case (.system, .dark): return .systemMaterialDark
        case (.systemThin, .auto): return .systemThinMaterial
        case (.systemThin, .light): return .systemThinMaterialLight
        case (.systemThin, .dark): return .systemThinMaterialDark
        case (.systemUltraThin, .auto): return .systemUltraThinMaterial
        case (.systemUltraThin, .light): return .systemUltraThinMaterialLight
        case (.systemUltraThin, .dark): return .systemUltraThinMaterialDark
        case (.systemThick, .auto): return .systemThickMaterial
        case (.systemThick, .light): return .systemThickMaterialLight
        case (.systemThick, .dark): return .systemThickMaterialDark
        case (.regular, .auto): return .regular
        case (.regular, .light): return .light
        case (.regular, .dark): return .dark
        }
    }
}

struct BackgroundBlurOptions
{
    @Option(name: "Style",
            description: "Choose the blur style to use. Free users use the System Thin style.",
            values: BackgroundBlurStyle.allCases,
            attributes: [.pro])
    var style: BackgroundBlurStyle = .systemThin
    
    @Option(name: "Brightness",
            description: "Choose the brightness the blur style should use.",
            values: BackgroundBlurBrightness.allCases)
    var brightness: BackgroundBlurBrightness = .auto
    
    @Option(name: "Tint Color",
            description: "Choose a color to tint the background blur. Pro user can use both a custom color and a dynamic battery color.",
            values: Settings.proFeaturesEnabled ? BackgroundBlurTintColor.allCases : [.none, .theme])
    var tintColor: BackgroundBlurTintColor = .none
    
    @Option(name: "Custom Tint Color",
            description: "Choose the color to use for the custom tint color.",
            attributes: [.pro, .hidden(when: {currentTintColor != .custom})])
    var customColor: Color = .orange
    
    @Option(name: "Tint Opacity",
            description: "Change the opacity of the color that tints the background blur.",
            range: 0.2...0.8,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var tintOpacity: Double = 0.5
     
    @Option(name: "Maintain Aspect Ratio",
            description: "When scaling the blurred image to fit the background, maintain the aspect ratio instead of stretching the image only to the edges.")
    var maintainAspect: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.backgroundBlur)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension BackgroundBlurOptions
{
    static var currentTintColor: BackgroundBlurTintColor
    {
        return Settings.controllerFeatures.backgroundBlur.tintColor
    }
}
