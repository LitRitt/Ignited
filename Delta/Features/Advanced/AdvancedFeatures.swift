//
//  AdvancedFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct AdvancedFeatures: FeatureContainer
{
    static let shared = AdvancedFeatures()
    
    @Feature(name: "Controller Skin Debugging",
             description: "Enable to show controller skin debugging features in the pause menu.",
             options: SkinDebugOptions())
    var skinDebug
    
    @Feature(name: "Power User Tools",
             description: "Access potentially dangerous tools. Useful for debugging or troubleshooting.",
             options: PowerUserOptions())
    var powerUser
    
    private init()
    {
        self.prepareFeatures()
    }
}
