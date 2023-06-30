//
//  ControllerSkinFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 6/28/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct ControllerSkinFeatures: FeatureContainer
{
    static let shared = ControllerSkinFeatures()
    
    @Feature(name: "Skin Customization",
             description: "Change the look of controller skins.",
             options: SkinCustomizationOptions())
    var skinCustomization
    
    @Feature(name: "Background Blur",
             description: "Use a live blurred game screen as the background of skins.",
             options: BackgroundBlurOptions())
    var backgroundBlur
    
    @Feature(name: "AirPlay Skins",
             description: "Customize the appearance of games when AirPlaying to your TV.",
             options: AirPlaySkinsOptions())
    var airPlaySkins
    
    private init()
    {
        self.prepareFeatures()
    }
}
