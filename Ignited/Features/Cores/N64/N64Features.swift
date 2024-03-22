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
    
    @Feature(name: "OpenGLES 3",
             description: "Enable to allow OpenGLES 3. This fixes graphical issues in some games, but may cause others to crash. After enabling the feature here, you must also enable it for individual games from the game's context menu.",
             options: N64OpenGLES3Options())
    var openGLES3
    
    @Feature(name: "Overscan",
             description: "Enable to allow Overscan settings. Overscan allows you to reduce the black borders in N64 games. Use the Overscan option in the pause menu to edit the values for that game.",
             options: N64OverscanOptions(),
             attributes: [.hidden(when: {true})])
    var overscan
    
    private init()
    {
        self.prepareFeatures()
    }
}
