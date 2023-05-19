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
    
    @Feature(name: "Grid Overlay",
             description: "Simulate a retro display by adding a grid overlay.")
    var gridOverlayGBC
    
    private init()
    {
        self.prepareFeatures()
    }
}
