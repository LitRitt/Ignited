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
    
    @Feature(name: "Pause Menu",
             description: "Change the order of button in the pause menu.",
             options: PauseMenuOptions(),
             attributes: [.permanent])
    var pauseMenu
    
    @Feature(name: "Game Audio",
             description: "Change how and when audio is played.",
             options: GameAudioOptions(),
             attributes: [.permanent])
    var gameAudio
    
    @Feature(name: "Game Screenshots",
             description: "Capture screenshots of gameplay to your files or photos.",
             options: GameScreenshotOptions(),
             attributes: [.permanent])
    var screenshots
    
    @Feature(name: "Fast Forward",
             description: "Speed up gameplay to save time.",
             options: FastForwardOptions(),
             attributes: [.permanent])
    var fastForward
    
    @Feature(name: "Rewind",
             description: "Automatically save state at a given interval on supported systems. Allows you to rewind to a recent game state to undo mistakes.",
             options: RewindOptions(),
             attributes: [.pro, .beta])
    var rewind
    
    @Feature(name: "Quick Settings Menu",
             description: "Access common gameplay settings quickly from the pause menu or a controller/skin button.",
             options: QuickSettingsOptions(),
             attributes: [.permanent])
    var quickSettings
    
    @Feature(name: "Save States",
             options: SaveStatesOptions(),
             attributes: [.hidden])
    var saveStates
    
    @Feature(name: "Auto Sync",
             attributes: [.hidden])
    var autoSync
    
    @Feature(name: "Cheat Codes",
             description: "Modify games using cheat codes. Supports Action Replay, Code Breaker, Game Genie, and GameShark codes on select systems.")
    var cheats
    
    @Feature(name: "Rotation Lock",
             description: "Make rotation lock available in the pause menu. Lets you lock your game in either portrait or landscape orientation.")
    var rotationLock
    
    @Feature(name: "Sustain Buttons",
             options: SustainButtonsOptions(),
             attributes: [.hidden])
    var sustainButtons
    
    @Feature(name: "Mic Support",
             attributes: [.hidden])
    var micSupport
    
    private init()
    {
        self.prepareFeatures()
    }
}
