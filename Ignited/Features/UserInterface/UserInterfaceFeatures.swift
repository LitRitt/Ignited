//
//  UserInterfaceFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct UserInterfaceFeatures: FeatureContainer
{
    static let shared = UserInterfaceFeatures()
    
    @Feature(name: "Theme",
             description: "Change the theme and color of the app.",
             options: ThemeOptions(),
             attributes: [.permanent])
    var theme
    
    @Feature(name: "App Icon",
             description: "Change the app's icon.",
             options: AppIconOptions(),
             attributes: [.permanent])
    var appIcon
    
    @Feature(name: "App Presets",
             description: "Select an app preset to change many settings and options at once.",
             options: AppPresetOptions(),
             attributes: [.permanent])
    var appPresets
    
    @Feature(name: "Toast Notifications",
             description: "Show toast notifications for various in-game actions.",
             options: ToastNotificationOptions())
    var toasts
    
    @Feature(name: "Status Bar",
             description: "Show status bar during gameplay to keep track of time and battery usage.",
             options: StatusBarOptions())
    var statusBar
    
    @Feature(name: "Random Game",
             options: RandomGameOptions(),
             attributes: [.hidden(when: {true})])
    var randomGame
    
    @Feature(name: "Game Previews",
             attributes: [.hidden(when: {true})])
    var previews
    
    private init()
    {
        self.prepareFeatures()
    }
}
