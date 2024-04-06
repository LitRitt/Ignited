//
//  StyleAndColorOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Features

import SwiftUI

enum StandardSkinColor: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case auto = "Auto"
    case white = "White"
    case black = "Black"
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
        case .auto:
            switch UIScreen.main.traitCollection.userInterfaceStyle
            {
            case .light where Settings.controllerFeatures.backgroundBlur.isEnabled: return UIColor.black
            case .light: return UIColor.white
            case .dark, .unspecified: return UIColor.white
            }
        case .white: return UIColor.white
        case .black: return UIColor.black
        case .theme: return UIColor.themeColor
        case .battery: return UIColor.batteryColor
        case .custom: return UIColor(Settings.standardSkinFeatures.styleAndColor.customColor)
        }
    }
    
    var uiColorSecondary: UIColor {
        switch self
        {
        case .auto:
            switch UIScreen.main.traitCollection.userInterfaceStyle
            {
            case .light:
                return UIColor.white
            case .dark, .unspecified:
                return UIColor.black
            }
        case .white: return UIColor.black
        case .black, .battery, .theme: return UIColor.white
        case .custom: return UIColor(Settings.standardSkinFeatures.styleAndColor.customColorSecondary)
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

enum StandardSkinStyle: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case filled = "Filled"
    case outline = "Outline"
    case both = "Filled + Outline"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        Text(description)
    }
    
    var pro: Bool {
        switch self
        {
        case .outline, .both: return true
        default: return false
        }
    }
}

struct StyleAndColorOptions
{
    @Option(name: "Style",
            description: "Choose the style to use for inputs. Pro users can access Outline and Filled + Outline styles.",
            values: StandardSkinStyle.allCases,
            attributes: [.pro])
    var style: StandardSkinStyle = .filled
    
    @Option(name: "Color",
            description: "Choose which color to use for inputs. Pro users can use both a custom color and a dynamic battery color.",
            values: StandardSkinColor.allCases.filter { !$0.pro || PurchaseManager.shared.hasUnlockedPro })
    var color: StandardSkinColor = .auto
    
    @Option(name: "Custom Color",
            description: "Choose the color to use for the custom color mode.",
            attributes: [.pro, .hidden(when: {currentColor != .custom})])
    var customColor: Color = .orange
    
    @Option(name: "Custom Secondary Color",
            description: "Choose the secondary color to use for the custom color mode. This color is used for the outlines on the Filled + Outline style.",
            attributes: [.pro, .hidden(when: {currentColor != .custom})])
    var customColorSecondary: Color = .white
    
    @Option(name: "Translucent",
            description: "Enable to make the inputs able to be translucent. Disable to make the inputs fully opaque.")
    var translucentInputs: Bool = true
    
    @Option(name: "Shadows",
            description: "Enable to draw shadows underneath inputs.")
    var shadows: Bool = true
    
    @Option(name: "Shadow Opacity",
            description: "Change the shadow opacity to use with the custom style option.",
            range: 0.0...1.0,
            step: 0.05,
            unit: "%",
            isPercentage: true,
            attributes: [.hidden(when: {!currentShadows})])
    var shadowOpacity: Double = 0.5
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.styleAndColor)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension StyleAndColorOptions
{
    static var currentColor: StandardSkinColor
    {
        return Settings.standardSkinFeatures.styleAndColor.color
    }
    
    static var currentShadows: Bool
    {
        return Settings.standardSkinFeatures.styleAndColor.shadows
    }
}
