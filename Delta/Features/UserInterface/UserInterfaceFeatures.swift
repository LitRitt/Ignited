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
    
    @Feature(name: "App Theme Color",
             description: "Change the accent color of the app.",
             options: ThemeColorOptions())
    var theme
    
    @Feature(name: "Alternate App Icon",
             description: "Change the app's icon.",
             options: AppIconOptions())
    var appIcon
    
    @Feature(name: "Tap & Hold Game Previews",
             description: "Preview games and save states when accessing the tap & hold menu on a game.")
    var previews
    
    @Feature(name: "Controller Skin Customization",
             description: "Change how controller skins look and behave.",
             options: ControllerSkinOptions())
    var skins
    
    private init()
    {
        self.prepareFeatures()
    }
}
