//
//  SkinDebugOptions.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import DeltaCore
import Features

extension DeltaCore.ControllerSkin.Device: LocalizedOptionValue
{
    var description: String {
        switch self
        {
        case .iphone: return "iPhone"
        case .ipad: return "iPad"
        case .tv: return "AirPlay TV"
        }
    }
    
    public var localizedDescription: Text {
        Text(self.description)
    }
}

extension DeltaCore.ControllerSkin.DisplayType: LocalizedOptionValue
{
    var description: String {
        switch self
        {
        case .standard: return "Standard"
        case .edgeToEdge: return "EdgeToEdge"
        case .splitView: return "SplitView"
        }
    }
    
    public var localizedDescription: Text {
        Text(self.description)
    }
}

struct SkinDebugOptions
{
    @Option
    var isOn: Bool = false
    
    @Option
    var skinEnabled: Bool = false
    
    @Option(name: "Show Unsupported Skins",
            description: "Enable to show all controller skins, not just the ones that support your device.")
    var unsupportedSkins: Bool = false
    
    @Option(name: "Override Traits",
            description: "Enable to use skins designed for other devices and display types. Useful for skin designers who don't have access to devices to test skins on. Shake device in-game to open a menu to pause and change or reset your device and display type. This takes precedence over the Shake to Open Quick Settings feature.")
    var traitOverride: Bool = false
    
    @Option
    var device: DeltaCore.ControllerSkin.Device = getCurrentDevice()
    
    @Option
    var defaultDevice: DeltaCore.ControllerSkin.Device = getCurrentDevice()
    
    @Option
    var displayType: DeltaCore.ControllerSkin.DisplayType = getCurrentDisplayType()
    
    @Option
    var defaultDisplayType: DeltaCore.ControllerSkin.DisplayType = getCurrentDisplayType()
    
    @Option(name: "AltSkin Toggle",
            description: "AltSkins (alternate skins) allow you to switch between 2 different versions of a skin. The skins can be swapped using a pause menu button, an optional skin button if provided, or this toggle if necessary. Not all skins support this feature. If you come back to this page while playing a game, you can check below if that skin supports AltSkins.")
    var useAlt: Bool = false
    
    @Option(name: "AltSkin Supported", description: "See if your current skin supports AltSkins.", detailView: { value in
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
    
    @Option(name: "Restore Defaults",
            description: "Reset all options to their default values.",
            detailView: { _ in
        Button("Restore Defaults") {
            PowerUserOptions.resetFeature(.skinDebug)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetSkinDebug: Bool = false
}

extension SkinDebugOptions
{
    static func getCurrentDevice() -> DeltaCore.ControllerSkin.Device
    {
        guard let topViewController = UIApplication.shared.topViewController(),
              let window = topViewController.view.window else { return .iphone }
        
        return DeltaCore.ControllerSkin.Traits.defaults(for: window).device
    }
    
    static func getCurrentDisplayType() -> DeltaCore.ControllerSkin.DisplayType
    {
        guard let topViewController = UIApplication.shared.topViewController(),
              let window = topViewController.view.window else { return .edgeToEdge }
        
        return DeltaCore.ControllerSkin.Traits.defaults(for: window).displayType
    }
}
