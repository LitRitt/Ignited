//
//  SoftwareSkinOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 2/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Features

import SwiftUI

enum SoftwareSkinColor: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
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
        case .custom: return UIColor(Settings.controllerFeatures.softwareSkin.customColor)
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
        case .custom: return UIColor(Settings.controllerFeatures.softwareSkin.customColorSecondary)
        }
    }
}

enum SoftwareSkinStyle: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
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

enum SoftwareSkinDirectionalInputType: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case dPad = "D-Pad"
    case thumbstick = "Thumbstick"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum SoftwareSkinABXYLayout: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case nintendo = "Nintendo"
    case xbox = "Xbox"
    case swapAB = "Swap A/B"
    case swapXY = "Swap X/Y"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum SoftwareSkinN64Layout: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case none = "Default"
    case swapLeft = "Swap Stick/D-Pad"
    case swapRight = "Swap Buttons/C"
    case swapBoth = "Swap Both"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

struct SoftwareSkinOptions
{
    @Option(name: "Style",
            description: "Choose the style to use for inputs.",
            values: SoftwareSkinStyle.allCases)
    var style: SoftwareSkinStyle = .filled
    
    @Option(name: "Color",
            description: "Choose which color to use for inputs.",
            values: SoftwareSkinColor.allCases)
    var color: SoftwareSkinColor = .white
    
    @Option(name: "Custom Color",
            description: "Choose the color to use for the custom color mode.")
    var customColor: Color = .orange
    
    @Option(name: "Custom Secondary Color",
            description: "Choose the secondary color to use for the custom color mode. This color is used for the outlines on the Filled Outline style.")
    var customColorSecondary: Color = .white
    
    @Option(name: "Directional Input",
            description: "Choose which input type to use for directional inputs. Does not affect N64.",
            values: SoftwareSkinDirectionalInputType.allCases)
    var directionalInputType: SoftwareSkinDirectionalInputType = .dPad
    
    @Option(name: "A,B,X,Y Layout",
            description: "Choose which layout to use for A, B, X, and Y inputs. Does not affect N64 or Sega systems.",
            values: SoftwareSkinABXYLayout.allCases)
    var abxyLayout: SoftwareSkinABXYLayout = .nintendo
    
    @Option(name: "N64 Layout",
            description: "Choose which layout to use for N64 inputs. Swaps the top and bottom input groups on either or both sides.",
            values: SoftwareSkinN64Layout.allCases)
    var n64Layout: SoftwareSkinN64Layout = .none
    
    @Option(name: "Translucent",
            description: "Enable to make the inputs able to be translucent. Disable to make the inputs fully opaque.")
    var translucentInputs: Bool = true
    
    @Option(name: "Fullscreen Landscape",
            description: "Enable to maximize the screen size in landscape. This may cause inputs to cover parts of the screen. Disable to fit the screen between the left and right side input areas.")
    var fullscreenLandscape: Bool = true
    
    @Option(name: "Shadows",
            description: "Enable to draw shadows underneath inputs.")
    var shadows: Bool = true
    
    @Option(name: "Custom Shadow Opacity",
            description: "Change the shadow opacity to use with the custom style option.",
            range: 0.0...1.0,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var shadowOpacity: Double = 0.7
    
    @Option(name: "Extended Edges",
            description: "Change the value to use for extended edges on inputs. Extended edges increase the area around an input that will activate that input when touched.",
            range: 0...20,
            step: 1,
            unit: "pt")
    var extendedEdges: Double = 10
    
    @Option(name: "Notch/Island Safe Area",
            description: "Adjust the safe area to avoid screens being drawn underneath an iPhone's notch or dynamic island.",
            range: 0...60,
            step: 1,
            unit: "pt")
    var safeArea: Double = 40
}
