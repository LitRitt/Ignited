//
//  PowerUser.swift
//  Delta
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features
import DeltaCore

struct PowerUserOptions
{
    @Option(name: "Clear Auto Save States",
            description: "This will delete all auto save states from every game. The auto-load save states feature relies on these auto save states to resume your game where you left off. Deleting them can be useful to reduce the size of your Sync backup.",
            detailView: { _ in
        Button("Clear Auto Save States") {
            clearAutoSaveStates()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var clearAutoSaves: String = ""
    
    @Option(name: "Reset All Album Artwork",
            description: "Resets the artwork for every game to the artwork provided by the database, if there is one.",
            detailView: { _ in
        Button("Reset All Album Artwork") {
            resetAllArtwork()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetArtwork: String = ""
    
    @Option(name: "Reset Build Counter",
            description: "Resets the internal variable that tracks the last update shown. Causes the updates screen to be shown at next launch.",
            detailView: { _ in
        Button("Reset Build Counter") {
            resetBuildCounter()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetBuildCounter: String = ""
    
    @Option(name: "Reset All Feature Settings",
            description: "Resets every single feature setting to their default values. This cannot be undone, please only do so if you are absolutely sure your issue cannot be solved by resetting an individual feature, or want to return to a stock Ignited experience.",
            detailView: { _ in
        Button("Reset All Feature Settings") {
            resetFeature(.allFeatures)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetAllSettings: String = ""
}

extension PowerUserOptions
{
    static func resetBuildCounter()
    {
        Settings.lastUpdateShown = 1
    }
    
    static func clearAutoSaveStates()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        let alertController = UIAlertController(title: NSLocalizedString("⚠️ Clear States? ⚠️", comment: ""), message: NSLocalizedString("This will delete all auto save states from every game. The auto-load save states feature relies on these auto save states to resume your game where you left off. Deleting them can be useful to reduce the size of your Sync backup.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = topViewController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            
            let gameFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
            gameFetchRequest.returnsObjectsAsFaults = false
            
            DatabaseManager.shared.performBackgroundTask { (context) in
                do
                {
                    let games = try gameFetchRequest.execute()
                    
                    for tempGame in games
                    {
                        let stateFetchRequest = SaveState.fetchRequest(for: tempGame, type: .auto)
                        
                        do
                        {
                            let saveStates = try stateFetchRequest.execute()
                            
                            for autoSaveState in saveStates
                            {
                                let saveState = context.object(with: autoSaveState.objectID)
                                context.delete(saveState)
                            }
                            context.saveWithErrorLogging()
                        }
                        catch
                        {
                            print("Failed to delete auto save states.")
                        }
                    }
                }
                catch
                {
                    print("Failed to fetch games.")
                }
            }
        }))
        
        alertController.addAction(.cancel)
        
        topViewController.present(alertController, animated: true, completion: nil)
    }
    
    static func resetAllArtwork()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        let alertController = UIAlertController(title: NSLocalizedString("⚠️ Reset Artwork? ⚠️", comment: ""), message: NSLocalizedString("This will reset the artwork for every game to the one provided by the games database used by Ignited. Do not proceed if you do not have backup of your custom artworks.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = topViewController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            
            let gameFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
            gameFetchRequest.returnsObjectsAsFaults = false
            
            DatabaseManager.shared.performBackgroundTask { (context) in
                do
                {
                    let games = try gameFetchRequest.execute()
                    
                    for game in games
                    {
                        DatabaseManager.shared.resetArtwork(for: game)
                    }
                }
                catch
                {
                    print("Failed to fetch games.")
                }
            }
        }))
        
        alertController.addAction(.cancel)
        
        topViewController.present(alertController, animated: true, completion: nil)
    }
    
    static func resetFeature(_ feature: Feature)
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        let alertController: UIAlertController
        
        switch feature
        {
        case .allFeatures:
            alertController = UIAlertController(title: NSLocalizedString("Reset All Feature Settings?", comment: ""), message: NSLocalizedString("This cannot be undone, please only do so if you are absolutely sure your issue cannot be solved by resetting an individual feature, or want to return to a stock Ignited experience.", comment: ""), preferredStyle: .alert)
            
        default:
            alertController = UIAlertController(title: NSLocalizedString("Restore Defaults?", comment: ""), message: nil, preferredStyle: .alert)
        }
        
        let resetAction: UIAlertAction
        
        switch feature
        {
        case .allFeatures:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                for feature in Feature.allCases
                {
                    feature.resetSettings()
                }
            })
            
        default:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                feature.resetSettings()
            })
        }
        
        alertController.popoverPresentationController?.sourceView = topViewController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(resetAction)
        alertController.addAction(.cancel)
        
        topViewController.present(alertController, animated: true, completion: nil)
    }
}
    
extension PowerUserOptions
{
    enum Feature: Int, CaseIterable
    {
        // GBC
        case gameboyPalettes
        // N64
        case n64Graphics
        // Gameplay
        case gameScreenshot
        case gameAudio
        case saveStateRewind
        case fastForward
        case quickSettings
        // Controllers and Skins
        case skinCustomization
        case backgroundBlur
        case controller
        // Games Collection
        case artworkCustomization
        case animatedArtwork
        case favoriteGames
        // User Interface
        case toastNotifications
        case statusBar
        case themeColor
        case appIcon
        case randomGame
        // Touch Feedback
        case touchVibration
        case touchAudio
        case touchOverlay
        // Advanced
        case skinDebug
        case allFeatures
        
        func resetSettings()
        {
            switch self
            {
            case .gameboyPalettes:
                GBCFeatures.shared.palettes.multiPalette = false
                GBCFeatures.shared.palettes.palette = .studio
                GBCFeatures.shared.palettes.spritePalette1 = .studio
                GBCFeatures.shared.palettes.spritePalette2 = .studio
                GBCFeatures.shared.palettes.customPalette1Color1 = Color(fromRGB: GameboyPalette.studio.colors[0])
                GBCFeatures.shared.palettes.customPalette1Color2 = Color(fromRGB: GameboyPalette.studio.colors[1])
                GBCFeatures.shared.palettes.customPalette1Color3 = Color(fromRGB: GameboyPalette.studio.colors[2])
                GBCFeatures.shared.palettes.customPalette1Color4 = Color(fromRGB: GameboyPalette.studio.colors[3])
                GBCFeatures.shared.palettes.customPalette2Color1 = Color(fromRGB: GameboyPalette.minty.colors[0])
                GBCFeatures.shared.palettes.customPalette2Color2 = Color(fromRGB: GameboyPalette.minty.colors[1])
                GBCFeatures.shared.palettes.customPalette2Color3 = Color(fromRGB: GameboyPalette.minty.colors[2])
                GBCFeatures.shared.palettes.customPalette2Color4 = Color(fromRGB: GameboyPalette.minty.colors[3])
                GBCFeatures.shared.palettes.customPalette3Color1 = Color(fromRGB: GameboyPalette.spacehaze.colors[0])
                GBCFeatures.shared.palettes.customPalette3Color2 = Color(fromRGB: GameboyPalette.spacehaze.colors[1])
                GBCFeatures.shared.palettes.customPalette3Color3 = Color(fromRGB: GameboyPalette.spacehaze.colors[2])
                GBCFeatures.shared.palettes.customPalette3Color4 = Color(fromRGB: GameboyPalette.spacehaze.colors[3])
                
            case .n64Graphics:
                N64Features.shared.n64graphics.graphicsAPI = .openGLES2
                
            case .gameScreenshot:
                GameplayFeatures.shared.screenshots.saveToFiles = true
                GameplayFeatures.shared.screenshots.saveToPhotos = false
                GameplayFeatures.shared.screenshots.playCountdown = false
                GameplayFeatures.shared.screenshots.size = nil
                
            case .gameAudio:
                GameplayFeatures.shared.gameAudio.volume = 1.0
                GameplayFeatures.shared.gameAudio.respectSilent = true
                GameplayFeatures.shared.gameAudio.playOver = true
                
            case .saveStateRewind:
                GameplayFeatures.shared.rewind.interval = 15
                GameplayFeatures.shared.rewind.maxStates = 30
                GameplayFeatures.shared.rewind.keepStates = true
                
            case .fastForward:
                GameplayFeatures.shared.fastForward.speed = 3.0
                GameplayFeatures.shared.fastForward.toggle = true
                GameplayFeatures.shared.fastForward.prompt = false
                GameplayFeatures.shared.fastForward.slowmo = false
                GameplayFeatures.shared.fastForward.unsafe = false
                
            case .quickSettings:
                GameplayFeatures.shared.quickSettings.quickActionsEnabled = true
                GameplayFeatures.shared.quickSettings.gameAudioEnabled = true
                GameplayFeatures.shared.quickSettings.expandedGameAudioEnabled = true
                GameplayFeatures.shared.quickSettings.fastForwardEnabled = true
                GameplayFeatures.shared.quickSettings.expandedFastForwardEnabled = true
                GameplayFeatures.shared.quickSettings.controllerSkinEnabled = true
                GameplayFeatures.shared.quickSettings.expandedControllerSkinEnabled = true
                GameplayFeatures.shared.quickSettings.backgroundBlurEnabled = true
                GameplayFeatures.shared.quickSettings.expandedBackgroundBlurEnabled = true
                GameplayFeatures.shared.quickSettings.colorPalettesEnabled = true
                
            case .skinCustomization:
                ControllerSkinFeatures.shared.skinCustomization.opacity = 0.7
                ControllerSkinFeatures.shared.skinCustomization.alwaysShow = false
                ControllerSkinFeatures.shared.skinCustomization.matchTheme = false
                ControllerSkinFeatures.shared.skinCustomization.backgroundColor = Color(red: 0/255, green: 0/255, blue: 0/255)
                
            case .backgroundBlur:
                ControllerSkinFeatures.shared.backgroundBlur.blurBackground = true
                ControllerSkinFeatures.shared.backgroundBlur.blurAirPlay = true
                ControllerSkinFeatures.shared.backgroundBlur.blurAspect = true
                ControllerSkinFeatures.shared.backgroundBlur.blurOverride = false
                ControllerSkinFeatures.shared.backgroundBlur.blurStrength = 1.0
                ControllerSkinFeatures.shared.backgroundBlur.blurBrightness = 0.0
                
            case .controller:
                ControllerSkinFeatures.shared.controller.triggerDeadzone = 0.15
                
            case .artworkCustomization:
                GamesCollectionFeatures.shared.artwork.sortOrder = .alphabeticalAZ
                GamesCollectionFeatures.shared.artwork.size = .medium
                GamesCollectionFeatures.shared.artwork.bgThemed = true
                GamesCollectionFeatures.shared.artwork.bgColor = Color(red: 253/255, green: 110/255, blue: 0/255)
                GamesCollectionFeatures.shared.artwork.bgOpacity = 0.7
                GamesCollectionFeatures.shared.artwork.titleSize = 1.0
                GamesCollectionFeatures.shared.artwork.titleMaxLines = 3
                GamesCollectionFeatures.shared.artwork.cornerRadius = 15
                GamesCollectionFeatures.shared.artwork.borderWidth = 1.2
                GamesCollectionFeatures.shared.artwork.shadowOpacity = 0.5
                
            case .animatedArtwork:
                GamesCollectionFeatures.shared.animation.animationSpeed = 1.0
                GamesCollectionFeatures.shared.animation.animationPause = 0
                GamesCollectionFeatures.shared.animation.animationMaxLength = 30
                
            case .favoriteGames:
                GamesCollectionFeatures.shared.favorites.favoriteSort = true
                GamesCollectionFeatures.shared.favorites.favoriteHighlight = true
                GamesCollectionFeatures.shared.favorites.favoriteColor = Color(red: 255/255, green: 234/255, blue: 0/255)
                GamesCollectionFeatures.shared.favorites.highlightIntensity = 0.7
                
            case .toastNotifications:
                UserInterfaceFeatures.shared.toasts.duration = 1.5
                UserInterfaceFeatures.shared.toasts.restart = true
                UserInterfaceFeatures.shared.toasts.gameSave = true
                UserInterfaceFeatures.shared.toasts.stateSave = true
                UserInterfaceFeatures.shared.toasts.stateLoad = true
                UserInterfaceFeatures.shared.toasts.fastForward = true
                UserInterfaceFeatures.shared.toasts.statusBar = true
                UserInterfaceFeatures.shared.toasts.screenshot = true
                UserInterfaceFeatures.shared.toasts.rotationLock = true
                UserInterfaceFeatures.shared.toasts.backgroundBlur = true
                UserInterfaceFeatures.shared.toasts.palette = true
                UserInterfaceFeatures.shared.toasts.altSkin = true
                UserInterfaceFeatures.shared.toasts.debug = true
                
            case .statusBar:
                UserInterfaceFeatures.shared.statusBar.isOn = false
                UserInterfaceFeatures.shared.statusBar.useToggle = false
                UserInterfaceFeatures.shared.statusBar.style = .light
                
            case .themeColor:
                UserInterfaceFeatures.shared.theme.accentColor = .orange
                UserInterfaceFeatures.shared.theme.useCustom = false
                UserInterfaceFeatures.shared.theme.customColor = Color(red: 253/255, green: 110/255, blue: 0/255)
                
            case .appIcon:
                UserInterfaceFeatures.shared.appIcon.useTheme = true
                UserInterfaceFeatures.shared.appIcon.alternateIcon = .normal
                
            case .randomGame:
                UserInterfaceFeatures.shared.randomGame.useCollection = false
                
            case .touchVibration:
                TouchFeedbackFeatures.shared.touchVibration.strength = 1.0
                TouchFeedbackFeatures.shared.touchVibration.buttonsEnabled = true
                TouchFeedbackFeatures.shared.touchVibration.sticksEnabled = true
                TouchFeedbackFeatures.shared.touchVibration.releaseEnabled = true
                
            case .touchAudio:
                TouchFeedbackFeatures.shared.touchAudio.sound = .tock
                TouchFeedbackFeatures.shared.touchAudio.useGameVolume = true
                TouchFeedbackFeatures.shared.touchAudio.buttonVolume = 1.0
                
            case .touchOverlay:
                TouchFeedbackFeatures.shared.touchOverlay.themed = true
                TouchFeedbackFeatures.shared.touchOverlay.overlayColor = Color(red: 255/255, green: 255/255, blue: 255/255)
                TouchFeedbackFeatures.shared.touchOverlay.style = .bubble
                TouchFeedbackFeatures.shared.touchOverlay.opacity = 1.0
                TouchFeedbackFeatures.shared.touchOverlay.size = 1.0
                
            case .skinDebug:
                AdvancedFeatures.shared.skinDebug.isOn = false
                AdvancedFeatures.shared.skinDebug.skinEnabled = false
                AdvancedFeatures.shared.skinDebug.device = nil
                AdvancedFeatures.shared.skinDebug.useAlt = false
                AdvancedFeatures.shared.skinDebug.hasAlt = false
                
            case .allFeatures:
                break
            }
        }
    }
}
