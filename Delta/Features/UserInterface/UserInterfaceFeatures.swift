//
//  UserInterfaceFeatures.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct UserInterfaceFeatures: FeatureContainer
{
    static let shared = UserInterfaceFeatures()
    
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
    
    @Feature(name: "App Icon",
             description: "Change the app's icon.",
             options: AppIconOptions())
    var appIcon
    
    @Feature(name: "Random Game Button",
             description: "Show a button on the toolbar to play a random game",
             options: RandomGameOptions(),
             hidden: true)
    var randomGame
    
    @Feature(name: "Game Previews",
             description: "Preview games and save states when accessing the tap & hold menu on a game.",
             hidden: true)
    var previews
    
    private init()
    {
        self.prepareFeatures()
    }
}
