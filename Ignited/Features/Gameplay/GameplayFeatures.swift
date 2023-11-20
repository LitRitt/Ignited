//
//  GameplayFeatures.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/30/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import Features

struct GameplayFeatures: FeatureContainer
{
    static let shared = GameplayFeatures()
    
    @Feature(name: "Game Audio",
             description: "Change how and when audio is played.",
             options: GameAudioOptions(),
             permanent: true)
    var gameAudio
    
    @Feature(name: "Game Screenshots",
             description: "Capture screenshots of gameplay to your files or photos.",
             options: GameScreenshotOptions(),
             permanent: true)
    var screenshots
    
    @Feature(name: "Fast Forward",
             description: "Speed up gameplay to save time.",
             options: FastForwardOptions(),
             permanent: true)
    var fastForward
    
    @Feature(name: "Rewind",
             description: "Automatically save state at a given interval on supported systems. Allows you to rewind to a recent game state to undo mistakes.",
             options: RewindOptions())
    var rewind
    
    @Feature(name: "Quick Settings Menu",
             description: "Access common gameplay settings quickly from the pause menu or a controller/skin button.",
             options: QuickSettingsOptions(),
             permanent: true)
    var quickSettings
    
    @Feature(name: "Save States",
             options: SaveStatesOptions(),
             hidden: true)
    var saveStates
    
    @Feature(name: "Auto Sync",
             hidden: true)
    var autoSync
    
    @Feature(name: "Cheat Codes",
             description: "Modify games using cheat codes. Supports Action Replay, Code Breaker, Game Genie, and GameShark codes on select systems.")
    var cheats
    
    @Feature(name: "Rotation Lock",
             description: "Make rotation lock available in the pause menu. Lets you lock your game in either portrait or landscape orientation.")
    var rotationLock
    
    private init()
    {
        self.prepareFeatures()
    }
}
