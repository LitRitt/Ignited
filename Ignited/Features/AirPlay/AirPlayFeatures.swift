//
//  AirPlayFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/5/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Features

struct AirPlayFeatures: FeatureContainer
{
    static let shared = AirPlayFeatures()
    
    @Feature(name: "Device",
             description: "Change how AirPlay affects your device during gameplay.",
             options: AirPlayDeviceOptions(),
             attributes: [.permanent])
    var device
    
    @Feature(name: "External Display",
             description: "Change how AirPlay affects your external display during gameplay.",
             options: AirPlayDisplayOptions(),
             attributes: [.permanent])
    var display
    
    @Feature(name: "Skins",
             description: "Customize the appearance of games when AirPlaying.",
             options: AirPlaySkinsOptions())
    var skins
    
    private init()
    {
        self.prepareFeatures()
    }
}
