//
//  CoreFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/10/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

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
    
    private init()
    {
        self.prepareFeatures()
    }
}
