//
//  TouchFeedbackFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct TouchFeedbackFeatures: FeatureContainer
{
    static let shared = TouchFeedbackFeatures()
    
    @Feature(name: "Touch Vibration",
             description: "Play vibrations when interacting with controller skins.",
             options: TouchFeedbackVibrationOptions())
    var touchVibration
    
    @Feature(name: "Touch Overlay",
             description: "Display an overlay when interacting with controller skins.",
             options: TouchFeedbackOverlayOptions())
    var touchOverlay
    
    @Feature(name: "Touch Sounds",
             description: "Play sounds when interacting with controller skins.",
             options: TouchFeedbackAudioOptions())
    var touchAudio
    
    private init()
    {
        self.prepareFeatures()
    }
}
