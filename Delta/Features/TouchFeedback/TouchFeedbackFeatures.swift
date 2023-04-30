//
//  TouchFeedbackFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import Features

struct TouchFeedbackFeatures: FeatureContainer
{
    static let shared = TouchFeedbackFeatures()
    
    @Feature(name: "Vibration",
             description: "Play vibrations when interacting with controller skins.",
             options: TouchFeedbackVibrationOptions())
    var vibration
    
    @Feature(name: "Audio",
             description: "Play sounds when interacting with controller skins.",
             options: TouchFeedbackAudioOptions())
    var audio
    
    @Feature(name: "Overlay",
             description: "Display an overlay when interacting with controller skins.",
             options: TouchFeedbackOverlayOptions())
    var overlay
    
    private init()
    {
        self.prepareFeatures()
    }
}
