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
    
    @Feature(name: "Game Boy Palettes",
             description: "Enable to change the color palette used for GB games.",
             options: GameboyPaletteOptions(),
             permanent: true)
    var palettes
    
    private init()
    {
        self.prepareFeatures()
    }
}
