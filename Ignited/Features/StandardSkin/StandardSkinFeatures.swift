//
//  StandardSkinFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 3/1/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import Features

struct StandardSkinFeatures: FeatureContainer
{
    static let shared = StandardSkinFeatures()
    
    @Feature(name: "Style and Color",
             description: "Change the visual appearance of the standard skins.",
             options: StyleAndColorOptions(),
             attributes: [.permanent])
    var styleAndColor
    
    @Feature(name: "Game Screens",
             description: "Change the style and layout of game screens.",
             options: GameScreenOptions(),
             attributes: [.permanent])
    var gameScreen
    
    @Feature(name: "Inputs and Layout",
             description: "Change the layout of controller inputs.",
             options: InputsAndLayoutOptions(),
             attributes: [.permanent])
    var inputsAndLayout
    
    private init()
    {
        self.prepareFeatures()
    }
}

