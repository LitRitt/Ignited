//
//  GBAFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/17/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Features

struct GBAFeatures: FeatureContainer
{
    static let shared = GBAFeatures()
    
    @Feature(name: "Emulation Core",
             description: "Change the emulator core to use for GBA games.",
             options: GBACoreOptions(),
             attributes: [.permanent])
    var core
    
    private init()
    {
        self.prepareFeatures()
    }
}
