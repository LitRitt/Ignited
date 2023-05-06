//
//  SkinDebug.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI

import Features

enum SkinDebugDevice: String, CaseIterable, CustomStringConvertible
{
    case standard = "Standard iPhone"
    case edgeToEdge = "EdgeToEdge iPhone"
    case ipad = "Standard iPad"
    case splitView = "SplitView iPad"
    
    var description: String {
        return self.rawValue
    }
}

extension SkinDebugDevice: LocalizedOptionValue
{
    var localizedDescription: Text {
        Text(self.description)
    }
    
    static var nilDescription: String {
        return "Don't Override"
    }
    
    static var localizedNilDescription: Text {
        Text(self.nilDescription)
    }
}

struct SkinDebugOptions
{
    @Option
    var isOn: Bool = false
    
    @Option
    var skinEnabled: Bool = false
    
    @Option(name: "Device Override",
            description: "Show a different device's controller skin while debugging. Useful for testing skins on devices you don't have access to.",
            values: SkinDebugDevice.allCases)
    var device: SkinDebugDevice? = nil
    
    @Option(name: "AltSkin Toggle",
            description: "AltSkins (alternate skins) allow you to switch between 2 different versions of a skin. The skins can be swapped using a pause menu button, an optional skin button if provided, or this toggle if necessary. Not all skins support this feature. If you come back to this page while playing a game, you can check below if that skin supports AltSkins.")
    var useAlt: Bool = false
    
    @Option(name: "AltSkin Supported", description: "See if your current skin supports AltSkins", detailView: { value in
        HStack {
            Text("Supports AltSkins")
            Spacer()
            
            if value.wrappedValue
            {
                Text("Yes").foregroundColor(.secondary)
            }
            else
            {
                Text("No").foregroundColor(.secondary)
            }
        }.displayInline()
    })
    var hasAlt: Bool = false
}
