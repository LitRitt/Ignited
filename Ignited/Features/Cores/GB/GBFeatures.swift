//
//  CoreFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/10/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import mGBADeltaCore

import Features

struct GBFeatures: FeatureContainer
{
    static let shared = GBFeatures()
    
    @Feature(name: "Emulation Core",
             description: "Change the emulator core to use for GB games.",
             options: GBCoreOptions(),
             attributes: [.permanent])
    var core
    
    @Feature(name: "Color Palettes",
             description: "Change the color palette to use for GB games.",
             options: GBPaletteOptions(),
             attributes: [.permanent])
    var palettes
    
    @Feature(name: "mGBA Settings",
             description: "Change the settings for the mGBA core.",
             options: MGBCOptions(),
             attributes: [.permanent, .hidden(when: {Settings.preferredCore(for: .gbc) != mGBC.core})])
    var mGBASettings
    
    private init()
    {
        self.prepareFeatures()
    }
}
