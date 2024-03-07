//
//  TouchFeedbackOverlayOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features
import DeltaCore

extension ButtonOverlayStyle: LocalizedOptionValue
{
    public var localizedDescription: Text {
        Text(self.description)
    }
}

enum TouchOverlayColor: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case auto = "Auto"
    case white = "White"
    case black = "Black"
    case theme = "Theme"
    case battery = "Battery"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
    
    var uiColor: UIColor {
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
            
        case .white: return UIColor.white
        case .black: return UIColor.black
        case .theme: return UIColor.themeColor
        case .battery: return UIColor.batteryColor
        case .custom: return UIColor(Settings.touchFeedbackFeatures.touchOverlay.customColor)
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

struct TouchFeedbackOverlayOptions
{
    @Option(name: "Color",
            description: "Choose the color to use for overlays. Battery and custom colors require Ignited Pro.",
            values: TouchOverlayColor.allCases.filter { !$0.pro || Settings.proFeaturesEnabled })
    var color: TouchOverlayColor = .auto
    
    @Option(name: "Custom Color",
            description: "Choose a custom color to use for overlays.",
            attributes: [.pro])
    var customColor: Color = .orange
    
    @Option(name: "Style",
            description: "Choose the style to use for overlays. Free users are limited to the default \"Bubble\" style.",
            values: ButtonOverlayStyle.allCases.filter { $0 == .bubble || Settings.proFeaturesEnabled },
            attributes: [.pro])
    var style: ButtonOverlayStyle = .bubble
    
    @Option(name: "Opacity",
            description: "Adjust the opacity of the overlays.",
            range: 0.25...1.00,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var opacity: Double = 1.0
    
    @Option(name: "Size",
            description: "Adjust the size of the overlays.",
            range: 0.70...1.30,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var size: Double = 1.0
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.touchOverlay)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
