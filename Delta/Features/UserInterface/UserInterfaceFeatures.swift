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
    
    @Feature(name: "Toast Notifications",
             description: "Show toast notifications as a confirmation for various in-game actions.",
             options: ToastNotificationOptions())
    var toasts
    
    @Feature(name: "Show Status Bar",
             description: "Show the Status Bar during gameplay.",
             options: StatusBarOptions())
    var statusBar
    
    @Feature(name: "Theme Color",
             description: "Change the accent color of the app.",
             options: ThemeColorOptions())
    var theme
    
    @Feature(name: "Alternate App Icon",
             description: "Change the app's icon.",
             options: AppIconOptions())
    var appIcon
    
    private init()
    {
        self.prepareFeatures()
    }
}
