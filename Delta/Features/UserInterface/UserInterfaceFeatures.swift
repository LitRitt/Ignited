//
//  UserInterfaceFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import Features

struct UserInterfaceFeatures: FeatureContainer
{
    static let shared = UserInterfaceFeatures()
    
    @Feature(name: "Game Artwork Customization",
             description: "Change the style of the game artwork.",
             options: GameArtworkOptions())
    var artwork
    
    @Feature(name: "Toast Notifications")
    var toasts
    
    @Feature(name: "Show Status Bar")
    var statusBar
    
    private init()
    {
        self.prepareFeatures()
    }
}
