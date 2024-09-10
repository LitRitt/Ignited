//
//  TouchFeedbackFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import UIKit
import Features

struct TouchFeedbackFeatures: FeatureContainer
{
    static let shared = TouchFeedbackFeatures()
    
    @Feature(name: "Touch Vibration",
             description: "Play vibrations when interacting with controller skins.",
             options: TouchFeedbackVibrationOptions(),
             attributes: [.hidden(when: { UIDevice.current.userInterfaceIdiom != .phone })])
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
