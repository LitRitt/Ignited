//
//  MGBCOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/21/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI

import Features

enum GBModel: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case auto = "Autodetect"
    case gb = "Game Boy"
    case sgb = "Super Game Boy"
    case gbc = "Game Boy Color"
    case gba = "Game Boy Advance"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum GBIdleOptimization: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case remove = "Remove Known"
    case detect = "Detect and Remove"
    case none = "Don't Remove"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

enum GBColorOverride: String, CaseIterable, CustomStringConvertible, LocalizedOptionValue
{
    case fallback = "Fallback"
    case sgb = "Super Game Boy"
    case cgb = "Game Boy Color"
    case none = "None"
    
    var description: String {
        return self.rawValue
    }
    
    var localizedDescription: Text {
        return Text(description)
    }
}

struct MGBCOptions
{
    @Option(name: "Game Boy Model",
            description: "Choose which Game Boy model to use. Autodetect will select the most appropriate model for the current game. Requires restarting the game.",
            values: GBModel.allCases)
    var model: GBModel = .auto
    
    @Option(name: "Palette Lookup",
            description: "Choose which method to use to determine the color palette. Fallback looks for SGB palettes first, then GBC palettes if none are found. Choose None use the custom palette colors.",
            values: GBColorOverride.allCases)
    var paletteLookup: GBColorOverride = .fallback
    
    @Option(name: "Use SGB Borders",
            description: "Display Super Game Boy borders for Super Game Boy enhanced games.")
    var sgbBorders: Bool = true
    
    @Option(name: "Idle Loop Removal",
            description: "Optimizes game performance by driving the GBA's CPU less hard. Use this on low-powered hardware if its struggling with game performance.",
            values: GBIdleOptimization.allCases)
    var idleOptimization: GBIdleOptimization = .remove
    
    @Option(name: "Frameskip",
            description: "Choose how much frames should be skipped to improve performance at the expense of visual smoothness.",
            values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    var frameskip: Int32 = 0
    
    @Option(name: "Accelerometer Sensitivity",
            description: "Adjust the sensitivity of the accelerometer used in some GBC games.",
            range: 0.70...1.30,
            step: 0.05,
            unit: "%",
            isPercentage: true)
    var accelerometerSensitivity: Double = 1.0
}
