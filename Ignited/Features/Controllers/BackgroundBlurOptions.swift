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
        case .custom: return UIColor(Settings.controllerFeatures.backgroundBlur.customColor)
        }
    }
}

extension UIBlurEffect.Style: CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    public var description: String {
        switch self
        {
        case .dark: return "Dark"
        case .light: return "Light"
        case .prominent: return "Prominent"
        case .regular: return "Regular"
        case .systemChromeMaterial: return "Chrome"
        case .systemChromeMaterialDark: return "Chrome Dark"
        case .systemChromeMaterialLight: return "Chrome Light"
        case .systemMaterial: return "System"
        case .systemMaterialDark: return "System Dark"
        case .systemMaterialLight: return "System Light"
        case .systemThickMaterial: return "Thick"
        case .systemThickMaterialDark: return "Thick Dark"
        case .systemThickMaterialLight: return "Thick Light"
        case .systemThinMaterial: return "Thin"
        case .systemThinMaterialDark: return "Thin Dark"
        case .systemThinMaterialLight: return "Thin Light"
        case .systemUltraThinMaterial: return "Ultra Thin"
        case .systemUltraThinMaterialDark: return "Ultra Thin Dark"
        case .systemUltraThinMaterialLight: return "Ultra Thin Light"
        default: return ""
        }
    }
    
    public var localizedDescription: Text {
        return Text(description)
    }
    
    static public var allCases: [UIBlurEffect.Style] {
        return [.regular, .prominent, .light, .dark, .systemMaterial, .systemMaterialLight, .systemMaterialDark, .systemThickMaterial, .systemThickMaterialLight, .systemThickMaterialDark, .systemThinMaterial, .systemThinMaterialLight, .systemThinMaterialDark, .systemUltraThinMaterial, .systemUltraThinMaterialLight, .systemUltraThinMaterialDark, .systemChromeMaterial, .systemChromeMaterialLight, .systemChromeMaterialDark]
    }
}

struct BackgroundBlurOptions
{
    @Option(name: "Style",
            description: "Choose the blur style to use.",
            values: UIBlurEffect.Style.allCases,
            attributes: [.pro])
    var style: UIBlurEffect.Style = .systemThinMaterial
    
    @Option(name: "Tint Color",
            description: "Choose a color to tint the background blur. Custom color require Ignited Pro.",
            values: Settings.proFeaturesEnabled ? BackgroundBlurTintColor.allCases : [.none, .theme])
    var tintColor: BackgroundBlurTintColor = .none
    
    @Option(name: "Custom Tint Color",
            description: "Choose the color to use for the custom tint color.",
            attributes: [.pro])
    var customColor: Color = .orange
    
    @Option(name: "Tint Opacity",
            description: "Change the opacity of the color that tints the background blur.",
            range: 0.2...0.8,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var tintOpacity: Double = 0.5
    
    @Option(name: "Show During AirPlay",
             description: "Display the blurred background during AirPlay.")
    var showDuringAirPlay: Bool = true
     
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
