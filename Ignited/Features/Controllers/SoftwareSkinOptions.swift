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
    case theme = "Theme"
    case custom = "Custom"
    
    var description: String {
        return rawValue
    }
    
    var localizedDescription: Text {
        Text(description)
    }
}

enum SoftwareSkinStyle: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case filled = "Filled"
    case outline = "Outline"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        Text(description)
    }
}

struct SoftwareSkinOptions
{
    @Option(name: "Style",
            description: "Choose the style to use for inputs.",
            values: SoftwareSkinStyle.allCases)
    var style: SoftwareSkinStyle = .filled
    
    @Option(name: "Color",
            description: "Choose which background color to use with the custom style option.",
            values: SoftwareSkinColor.allCases)
    var color: SoftwareSkinColor = .white
    
    @Option(name: "Custom Color",
            description: "Choose the color to use for the custom color mode.")
    var customColor: Color = .orange
    
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
    
    @Option(name: "Translucent",
            description: "Enable to make the inputs able to be translucent. Disable to make the inputs fully opaque.")
    var translucentInputs: Bool = true
    
    @Option(name: "Fullscreen Landscape",
            description: "Enable to maximize the screen size in landscape. This may cause inputs to cover parts of the screen. Disable to fit the screen between the left and right side input areas.")
    var fullscreenLandscape: Bool = true
}
