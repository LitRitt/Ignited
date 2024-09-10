//
//  SkinOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/2/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum SkinThumbstickMode: String, CaseIterable, CustomStringConvertible
{
    case relative = "Relative"
    case absolute = "Absolute"
    
    var description: String {
        return self.rawValue
    }
}

extension SkinThumbstickMode: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

enum SkinBackgroundColor: String, CaseIterable, CustomStringConvertible
{
    case none = "None"
    case theme = "Theme"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
    
    var uiColor: UIColor {
        switch self {
        case .none: return .black
        case .theme: return Settings.userInterfaceFeatures.theme.color.uiColor
        case .custom: return UIColor(Settings.controllerFeatures.skin.backgroundColor)
        }
    }
}

extension SkinBackgroundColor: LocalizedOptionValue
{
    var localizedDescription: Text {
        return Text(self.description)
    }
}

struct SkinOptions
{
    @Option(name: "Background Color Mode",
            description: "Choose which color to use for the controller skin background. Pro users can select a custom color.",
            values: Settings.proFeaturesEnabled ? SkinBackgroundColor.allCases : [.none, .theme])
    var colorMode: SkinBackgroundColor = .none
    
    @Option(name: "Custom Background Color",
            description: "Select a custom color to use as the controller skin background.",
            attributes: [.pro, .hidden(when: {currentColorMode != .custom})])
    var backgroundColor: Color = .black
    
    @Option(name: "Opacity",
            description: "Change the opacity of supported controller skins.",
            range: 0.0...1.00,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var opacity: Double = 0.7
    
    @Option(name: "Thumbstick Mode",
            description: "Change the way thumbsticks on skins behave.\n\nRelative: The middle of the stick is where you first touch. Use this for touchscreen input.\n\nAbsolute: The middle of the stick is where the skin shows it. Use this for controller cases like PlayCase.",
            values: SkinThumbstickMode.allCases,
            attributes: [.hidden(when: { Settings.controllerFeatures.playCase.isEnabled })])
    var thumbstickMode: SkinThumbstickMode = .relative
    
    @Option(name: "Diagonal D-Pad Inputs",
            description: "Enable to allow diagonal inputs on the corners of the D-Pad.")
    var diagonalDpad: Bool = true
    
    @Option(name: "Ignore Input Frames",
            description: "Enable to ignore the inputFrame provided by skins. Fixes improper cropping on legacy skins. Does not affect DS skins.",
            attributes: [.hidden(when: {false})])
    var ignoreInputFrames: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.skin)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}

extension SkinOptions
{
    static var currentColorMode: SkinBackgroundColor
    {
        return Settings.controllerFeatures.skin.colorMode
    }
}
