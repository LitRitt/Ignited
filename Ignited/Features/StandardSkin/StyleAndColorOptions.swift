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
    case white = "White"
    case black = "Black"
    case auto = "Auto"
    case theme = "Theme"
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
            case .light:
                return UIColor.black
            case .dark, .unspecified:
                return UIColor.white
            }
        case .white: return UIColor.white
        case .black: return UIColor.black
        case .theme: return UIColor.themeColor
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
        case .black: return UIColor.white
        case .theme: return UIColor.white
        case .custom: return UIColor(Settings.standardSkinFeatures.styleAndColor.customColorSecondary)
        }
    }
}

enum StandardSkinStyle: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case filled = "Filled"
    case outline = "Outline"
    case both = "Both"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        Text(description)
    }
}

struct StyleAndColorOptions
{
    @Option(name: "Style",
            description: "Choose the style to use for inputs.",
            values: StandardSkinStyle.allCases)
    var style: StandardSkinStyle = .filled
    
    @Option(name: "Color",
            description: "Choose which color to use for inputs.",
            values: StandardSkinColor.allCases)
    var color: StandardSkinColor = .white
    
    @Option(name: "Custom Color",
            description: "Choose the color to use for the custom color mode.")
    var customColor: Color = .orange
    
    @Option(name: "Custom Secondary Color",
            description: "Choose the secondary color to use for the custom color mode. This color is used for the outlines on the Filled Outline style.")
    var customColorSecondary: Color = .white
    
    @Option(name: "Translucent",
            description: "Enable to make the inputs able to be translucent. Disable to make the inputs fully opaque.")
    var translucentInputs: Bool = true
    
    @Option(name: "Shadows",
            description: "Enable to draw shadows underneath inputs.")
    var shadows: Bool = true
    
    @Option(name: "Custom Shadow Opacity",
            description: "Change the shadow opacity to use with the custom style option.",
            range: 0.0...1.0,
            step: 0.05,
            unit: "%",
            isPercentage: true)
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

