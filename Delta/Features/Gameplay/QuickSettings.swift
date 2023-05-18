//
//  QuickSettings.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/14/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

struct QuickSettingsOptions
{
    @Option(name: "Quick Actions",
            description: "Enable to show common actions in the quick settings.")
    var quickActionsEnabled: Bool = true
    
    @Option
    var performQuickSave: Bool = false
    
    @Option
    var performQuickLoad: Bool = false
    
    @Option
    var performScreenshot: Bool = false
    
    @Option
    var performPause: Bool = false
    
    @Option(name: "Game Audio",
            description: "Enable to show game audio options in the quick settings.")
    var gameAudioEnabled: Bool = true
    
    @Option(name: "Expanded Game Audio",
            description: "Enable to show more game audio options in the quick settings.")
    var expandedGameAudioEnabled: Bool = false
    
    @Option(name: "Fast Forward",
            description: "Enable to show fast forward options in the quick settings.")
    var fastForwardEnabled: Bool = true
    
    @Option(name: "Expanded Fast Forward",
            description: "Enable to show more fast forward options in the quick settings.")
    var expandedFastForwardEnabled: Bool = false
    
    @Option
    var fastForwardSpeed: Double = 1.0
    
    @Option(name: "Color Palettes",
            description: "Enable to show color palette options in the quick settings.")
    var colorPalettesEnabled: Bool = true
}
