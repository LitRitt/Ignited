//
//  Features.swift
//  Delta
//
//  Created by Chris Rittenhouse on 4/29/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import Features

struct Features: FeatureContainer
{
    static let shared = Features()
    
    @Feature(name: "Show Status Bar",
             description: "Enable to show the Status Bar during gameplay.")
    var showStatusBar
    
    @Feature(name: "Game Screenshots",
             description: "When enabled, a Screenshot button will appear in the Pause Menu, allowing you to save a screenshot of your game. You can choose to save the screenshot to Photos or Files.",
             options: GameScreenshotsOptions())
    var gameScreenshots
    
    @Feature(name: "Toast Notifications",
             description: "Show toast notifications as a confirmation for various actions, such as saving your game or loading a save state.",
             options: ToastNotificationOptions())
    var toastNotifications
    
    private init()
    {
        self.prepareFeatures()
    }
}
