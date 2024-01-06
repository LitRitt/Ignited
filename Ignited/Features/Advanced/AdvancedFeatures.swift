//
//  AdvancedFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct AdvancedFeatures: FeatureContainer
{
    static let shared = AdvancedFeatures()
    
    @Feature(name: "Power User Tools",
             description: "Intended for troubleshooting and other power user tasks. ",
             options: PowerUserOptions())
    var powerUser
    
    @Feature(name: "Controller Skin Debugging",
             description: "Useful for creating and debugging controller skins.",
             options: SkinDebugOptions())
    var skinDebug
    
    #if DEBUG
    @Feature(name: "Enable Pro",
             description: "For testing Ignited Pro features.")
    var proOverride
    #else
    @Feature(name: "Enable Pro",
             description: "For testing Ignited Pro features.",
             hidden: true)
    var proOverride
    #endif
    
    private init()
    {
        self.prepareFeatures()
    }
}
