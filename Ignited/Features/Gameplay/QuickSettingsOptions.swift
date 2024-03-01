//
//  QuickSettingsOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/14/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features

extension ActionInput: CustomStringConvertible
{
    var description: String {
        switch self
        {
        case .fastForward: return "Fast Forward"
        case .quickSave: return "Quick Save"
        case .quickLoad: return "Quick Load"
        case .screenshot: return "Screenshot"
        case .restart: return "Restart"
        default: return "Unsupported"
        }
    }
}

extension ActionInput: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
    
    static var localizedNilDescription: Text {
        Text("Don't Replace")
    }
}

struct QuickSettingsOptions
{
    @Option(name: "Shake to Open",
            description: "Enable to open the quick settings menu by shaking your device.")
    var shakeToOpen: Bool = false
    
    @Option(name: "Replace Button",
            description: "Choose an input, like fast forward or screenshot, to use with the quick settings button on skins instead of opening the quick settings menu.",
            values: [ActionInput.fastForward, ActionInput.quickSave, ActionInput.quickLoad, ActionInput.screenshot, ActionInput.restart])
    var buttonReplacement: ActionInput? = nil
    
    @Option(name: "Quick Actions",
            description: "Enable to show common actions in the quick settings.")
    var quickActionsEnabled: Bool = true
    
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
    
    @Option(name: "Standard Skin",
            description: "Enable to show standard skin options in the quick settings.")
    var standardSkinEnabled: Bool = true
    
    @Option(name: "Controller Skin",
            description: "Enable to show controller skin options in the quick settings.")
    var controllerSkinEnabled: Bool = true
    
    @Option(name: "Background Blur",
            description: "Enable to show background blur options in the quick settings.")
    var backgroundBlurEnabled: Bool = true
    
    @Option(name: "Color Palettes",
            description: "Enable to show color palette options in the quick settings.")
    var colorPalettesEnabled: Bool = true
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.quickSettings)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var reset: Bool = false
}
