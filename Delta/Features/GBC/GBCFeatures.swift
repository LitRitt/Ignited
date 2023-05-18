//
//  CoreFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/10/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import Features

struct GBCFeatures: FeatureContainer
{
    static let shared = GBCFeatures()
    
    @Feature(name: "Game Boy Palettes",
             description: "Enable to change the color palette used for GB games.",
             options: GameboyPaletteOptions())
    var palettes
    
    @Feature(name: "Shader",
             description: "Simulate a retro display by applying a pixel shader.")
    var shader
    
    private init()
    {
        self.prepareFeatures()
    }
}
