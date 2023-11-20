//
//  N64Features.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 6/11/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct N64Features: FeatureContainer
{
    static let shared = N64Features()
    
    @Feature(name: "Graphics",
             description: "Enable to customize the graphics options.",
             options: N64GraphicsOptions())
    var n64graphics
    
    private init()
    {
        self.prepareFeatures()
    }
}
