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
             hidden: true)
    var statusBar
    
    @Feature(name: "Theme",
             description: "Change the colors of the app.",
             options: ThemeOptions())
    var theme
    
    @Feature(name: "App Icon",
             description: "Change the app's icon.",
             options: AppIconOptions())
    var appIcon
    
    @Feature(name: "Random Game",
             options: RandomGameOptions(),
             hidden: true)
    var randomGame
    
    @Feature(name: "Game Previews",
             hidden: true)
    var previews
    
    private init()
    {
        self.prepareFeatures()
    }
}
