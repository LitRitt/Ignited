//
//  SNESFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 1/9/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Features

struct SNESFeatures: FeatureContainer
{
    static let shared = SNESFeatures()
    
    @Feature(name: "Invalid VRAM Access",
             description: "Enable to allow invalid VRAM access. This allows some games to properly display chinese fonts.\n\n⚠️ Do not enable this feature if you don't know what you're doing.")
    var allowInvalidVRAMAccess
    
    private init()
    {
        self.prepareFeatures()
    }
}
