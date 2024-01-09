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
             description: "Enable to allow invalid VRAM access. After enabling the feature here, you must also enable it for individual games from the game's context menu.",
             options: SNESInvalidVRAMOptions())
    var allowInvalidVRAMAccess
    
    private init()
    {
        self.prepareFeatures()
    }
}
