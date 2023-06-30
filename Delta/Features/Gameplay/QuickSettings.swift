//
//  QuickSettings.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/14/23.
//  Copyright © 2023 LitRitt. All rights reserved.
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
    
    @Option
    var performMainMenu: Bool = false
    
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
    
    @Option(name: "Controller Skin",
            description: "Enable to show controller skin options in the quick settings.")
    var controllerSkinEnabled: Bool = true
    
    @Option(name: "Expanded Controller Skin",
            description: "Enable to show more controller skin options in the quick settings.")
    var expandedControllerSkinEnabled: Bool = false
    
    @Option(name: "Background Blur",
            description: "Enable to show background blur options in the quick settings.")
    var backgroundBlurEnabled: Bool = true
    
    @Option(name: "Expanded Background Blur",
            description: "Enable to show more background blur options in the quick settings.")
    var expandedBackgroundBlurEnabled: Bool = false
    
    @Option(name: "Color Palettes",
            description: "Enable to show color palette options in the quick settings.")
    var colorPalettesEnabled: Bool = true
    
    @Option(name: "Restore Defaults", description: "Reset all options to their default values.", detailView: { value in
        Toggle(isOn: value) {
            Text("Restore Defaults")
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.red)
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .displayInline()
    })
    var resetQuickSettings: Bool = false
}
