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
        case .statusBar: return "Status Bar"
        case .restart: return "Restart"
        case .quickSettings: return "Quick Settings"
        case .toggleAltRepresentations: return "Toggle AltSkin"
        case .null: return "None"
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
        Text("None")
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
