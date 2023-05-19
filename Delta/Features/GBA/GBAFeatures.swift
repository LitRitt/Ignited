//
//  GBAFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/19/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import Features

struct GBAFeatures: FeatureContainer
{
    static let shared = GBAFeatures()
    
    @Feature(name: "Grid Overlay",
             description: "Simulate a retro display by adding a grid overlay.")
    var gridOverlayGBA
    
    private init()
    {
        self.prepareFeatures()
    }
}
