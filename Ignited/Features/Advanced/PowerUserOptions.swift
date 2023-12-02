//
//  PowerUserOptions.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 5/1/23.
//  Copyright © 2023 LitRitt. All rights reserved.
//

import SwiftUI

import Features
import DeltaCore

import Harmony
import Roxas

struct PowerUserOptions
{
    @Option(name: "Fix Game Collection Associations",
            description: "This will fix any games that are associated with the wrong collections.",
            detailView: { _ in
        Button("Fix Game Collection Associations") {
            fixGameCollections()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var fixGameCollections: String = ""
    
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
            description: "This resets the artwork for every game to what it was when it was imported.",
            detailView: { _ in
        Button("Reset All Album Artwork") {
            resetAllArtwork()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetArtwork: String = ""
    
    @Option(name: "Reset All Feature Settings",
            description: "This resets every feature setting to its default state.",
            detailView: { _ in
        Button("Reset All Feature Settings") {
            resetFeature(.allFeatures)
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetAllSettings: String = ""
    
    @Option(name: "Copy Google Drive Refresh Token",
            description: "This token will allow other applications and services to access the files in your Google Drive Ignited Sync backup, including games, saves, states, skins, and cheats. Do not give it away to anyone, and only use it if you trust the application that you use it with.",
            detailView: { _ in
        Button("Copy Google Drive Refresh Token") {
            copyGoogleDriveRefreshToken()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var copyGoogleDriveRefreshToken: String = ""
    
    @Option(name: "Reset Build Counter",
            description: "This will force update actions, such as repairs, to be taken next app launch.",
            detailView: { _ in
        Button("Reset Build Counter") {
            Settings.lastUpdateShown = 1
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetBuildCounter: String = ""
}

extension PowerUserOptions
{
    static func fixGameCollections()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledNotification(topViewController)
            return
        }
        
        DatabaseManager.shared.repairGameCollections(repairAll: true)
        
        let toast = RSTToastView(text: NSLocalizedString("Fixed Game Collections", comment: ""), detailText: nil)
        toast.show(in: topViewController.view, duration: 5.0)
    }
    
    static func copyGoogleDriveRefreshToken()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledNotification(topViewController)
            return
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("Copy Refresh Token?", comment: ""), message: NSLocalizedString("This token will allow other applications and services to access the files in your Google Drive Ignited Sync backup, including games, saves, states, skins, and cheats. Do not give it away to anyone, and only use it if you trust the application that you use it with.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = topViewController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
            
            guard let coordinator = SyncManager.shared.coordinator else
            {
                let toast = RSTToastView(text: NSLocalizedString("Failed to copy token", comment: ""), detailText: NSLocalizedString("You must enable Ignited Sync and use the Google Drive service.", comment: ""))
                toast.show(in: topViewController.view, duration: 5.0)
                return
            }
            
            guard let service = coordinator.service as? DriveService,
                  let token = service.refreshToken else
            {
                let toast = RSTToastView(text: NSLocalizedString("Failed to copy token", comment: ""), detailText: NSLocalizedString("You must use the Google Drive service with Ignited Sync. The Dropbox service is not supported.", comment: ""))
                toast.show(in: topViewController.view, duration: 5.0)
                return
            }

            UIPasteboard.general.string = token
            let toast = RSTToastView(text: NSLocalizedString("Successfully copied token", comment: ""), detailText: NSLocalizedString("Paste it in a safe place, and only use it with applications and services you trust.", comment: ""))
            toast.show(in: topViewController.view, duration: 5.0)
        }))
        
        alertController.addAction(.cancel)
        
        topViewController.present(alertController, animated: true, completion: nil)
    }

    static func clearAutoSaveStates()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledNotification(topViewController)
            return
        }
        
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
        
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledNotification(topViewController)
            return
        }
        
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
            guard Settings.advancedFeatures.powerUser.isEnabled else {
                self.showFeatureDisabledNotification(topViewController)
                return
            }
            
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
    
    static func showFeatureDisabledNotification(_ viewController: UIViewController)
    {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("You must enable Power User Tools via the toggle on the previous page to use these options.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = viewController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in }))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
    
extension PowerUserOptions
{
    enum Feature: Int, CaseIterable
    {
        // GB
        case gameboyPalettes
        // N64
        case n64Graphics
        // Gameplay
        case gameScreenshot
        case gameAudio
        case saveStateRewind
        case fastForward
        case quickSettings
        // Controllers
        case skin
        case backgroundBlur
        case controller
        // Library
        case artworkCustomization
        case animatedArtwork
        case favoriteGames
        // User Interface
        case toastNotifications
        case theme
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
                Settings.gbFeatures.palettes.multiPalette = false
                Settings.gbFeatures.palettes.palette = .studio
                Settings.gbFeatures.palettes.spritePalette1 = .studio
                Settings.gbFeatures.palettes.spritePalette2 = .studio
                Settings.gbFeatures.palettes.customPalette1Color1 = Color(fromRGB: GameboyPalette.studio.colors[0])
                Settings.gbFeatures.palettes.customPalette1Color2 = Color(fromRGB: GameboyPalette.studio.colors[1])
                Settings.gbFeatures.palettes.customPalette1Color3 = Color(fromRGB: GameboyPalette.studio.colors[2])
                Settings.gbFeatures.palettes.customPalette1Color4 = Color(fromRGB: GameboyPalette.studio.colors[3])
                Settings.gbFeatures.palettes.customPalette2Color1 = Color(fromRGB: GameboyPalette.minty.colors[0])
                Settings.gbFeatures.palettes.customPalette2Color2 = Color(fromRGB: GameboyPalette.minty.colors[1])
                Settings.gbFeatures.palettes.customPalette2Color3 = Color(fromRGB: GameboyPalette.minty.colors[2])
                Settings.gbFeatures.palettes.customPalette2Color4 = Color(fromRGB: GameboyPalette.minty.colors[3])
                Settings.gbFeatures.palettes.customPalette3Color1 = Color(fromRGB: GameboyPalette.spacehaze.colors[0])
                Settings.gbFeatures.palettes.customPalette3Color2 = Color(fromRGB: GameboyPalette.spacehaze.colors[1])
                Settings.gbFeatures.palettes.customPalette3Color3 = Color(fromRGB: GameboyPalette.spacehaze.colors[2])
                Settings.gbFeatures.palettes.customPalette3Color4 = Color(fromRGB: GameboyPalette.spacehaze.colors[3])
                
            case .n64Graphics:
                Settings.n64Features.n64graphics.graphicsAPI = .openGLES2
                
            case .gameScreenshot:
                Settings.gameplayFeatures.screenshots.saveLocation = .photos
                Settings.gameplayFeatures.screenshots.size = .x5
                
            case .gameAudio:
                Settings.gameplayFeatures.gameAudio.volume = 1.0
                Settings.gameplayFeatures.gameAudio.respectSilent = true
                Settings.gameplayFeatures.gameAudio.playOver = true
                
            case .saveStateRewind:
                Settings.gameplayFeatures.rewind.interval = 15
                Settings.gameplayFeatures.rewind.maxStates = 30
                Settings.gameplayFeatures.rewind.keepStates = true
                
            case .fastForward:
                Settings.gameplayFeatures.fastForward.speed = 3.0
                Settings.gameplayFeatures.fastForward.mode = .toggle
                
            case .quickSettings:
                Settings.gameplayFeatures.quickSettings.quickActionsEnabled = true
                Settings.gameplayFeatures.quickSettings.gameAudioEnabled = true
                Settings.gameplayFeatures.quickSettings.expandedGameAudioEnabled = false
                Settings.gameplayFeatures.quickSettings.fastForwardEnabled = true
                Settings.gameplayFeatures.quickSettings.expandedFastForwardEnabled = false
                Settings.gameplayFeatures.quickSettings.controllerSkinEnabled = true
                Settings.gameplayFeatures.quickSettings.expandedControllerSkinEnabled = false
                Settings.gameplayFeatures.quickSettings.backgroundBlurEnabled = true
                Settings.gameplayFeatures.quickSettings.expandedBackgroundBlurEnabled = false
                Settings.gameplayFeatures.quickSettings.colorPalettesEnabled = true
                
            case .skin:
                Settings.controllerFeatures.skin.opacity = 0.7
                Settings.controllerFeatures.skin.alwaysShow = false
                Settings.controllerFeatures.skin.colorMode = .none
                Settings.controllerFeatures.skin.backgroundColor = .black
                
            case .backgroundBlur:
                Settings.controllerFeatures.backgroundBlur.overrideSetting = true
                Settings.controllerFeatures.backgroundBlur.showDuringAirPlay = true
                Settings.controllerFeatures.backgroundBlur.maintainAspect = true
                Settings.controllerFeatures.backgroundBlur.overrideSkin = false
                Settings.controllerFeatures.backgroundBlur.strength = 1.0
                Settings.controllerFeatures.backgroundBlur.tintIntensity = 0.1
                
            case .controller:
                Settings.controllerFeatures.controller.triggerDeadzone = 0.15
                
            case .artworkCustomization:
                Settings.libraryFeatures.artwork.sortOrder = .alphabeticalAZ
                Settings.libraryFeatures.artwork.size = .medium
                Settings.libraryFeatures.artwork.style = .basic
                Settings.libraryFeatures.artwork.backgroundColorMode = .custom
                Settings.libraryFeatures.artwork.backgroundColor = .orange
                Settings.libraryFeatures.artwork.borderColorMode = .custom
                Settings.libraryFeatures.artwork.borderColor = .orange
                Settings.libraryFeatures.artwork.textColorMode = .theme
                Settings.libraryFeatures.artwork.textColor = .black
                Settings.libraryFeatures.artwork.shadowColorMode = .theme
                Settings.libraryFeatures.artwork.shadowColor = .white
                Settings.libraryFeatures.artwork.cornerRadius = 0.15
                Settings.libraryFeatures.artwork.borderWidth = 1.5
                Settings.libraryFeatures.artwork.shadowOpacity = 0.5
                Settings.libraryFeatures.artwork.useScreenshots = true
                Settings.libraryFeatures.artwork.showNewGames = true
                Settings.libraryFeatures.artwork.forceAspect = true
                Settings.libraryFeatures.artwork.titleSize = 1.0
                Settings.libraryFeatures.artwork.titleMaxLines = 3
                
            case .animatedArtwork:
                Settings.libraryFeatures.animation.animationSpeed = 1.0
                Settings.libraryFeatures.animation.animationPause = 0
                Settings.libraryFeatures.animation.animationMaxLength = 30
                
            case .favoriteGames:
                Settings.libraryFeatures.favorites.sortFirst = true
                Settings.libraryFeatures.favorites.style = .theme
                Settings.libraryFeatures.favorites.backgroundColorMode = .custom
                Settings.libraryFeatures.favorites.backgroundColor = .orange
                Settings.libraryFeatures.favorites.borderColorMode = .custom
                Settings.libraryFeatures.favorites.borderColor = .orange
                Settings.libraryFeatures.favorites.textColorMode = .theme
                Settings.libraryFeatures.favorites.textColor = .black
                Settings.libraryFeatures.favorites.shadowColorMode = .theme
                Settings.libraryFeatures.favorites.shadowColor = .white
                
            case .toastNotifications:
                Settings.userInterfaceFeatures.toasts.duration = 1.5
                Settings.userInterfaceFeatures.toasts.restart = true
                Settings.userInterfaceFeatures.toasts.gameSave = false
                Settings.userInterfaceFeatures.toasts.stateSave = true
                Settings.userInterfaceFeatures.toasts.stateLoad = true
                Settings.userInterfaceFeatures.toasts.fastForward = true
                Settings.userInterfaceFeatures.toasts.statusBar = true
                Settings.userInterfaceFeatures.toasts.screenshot = true
                Settings.userInterfaceFeatures.toasts.rotationLock = true
                Settings.userInterfaceFeatures.toasts.backgroundBlur = true
                Settings.userInterfaceFeatures.toasts.palette = true
                Settings.userInterfaceFeatures.toasts.altSkin = true
                Settings.userInterfaceFeatures.toasts.debug = true
                
            case .theme:
                Settings.userInterfaceFeatures.theme.style = .auto
                Settings.userInterfaceFeatures.theme.color = .orange
                Settings.userInterfaceFeatures.theme.lightColor = .accentColor
                Settings.userInterfaceFeatures.theme.darkColor = .accentColor
                Settings.userInterfaceFeatures.theme.lightFavoriteColor = .accentColor
                Settings.userInterfaceFeatures.theme.darkFavoriteColor = .accentColor
                
            case .appIcon:
                Settings.userInterfaceFeatures.appIcon.alternateIcon = .normal
                AppIconOptions.updateAppIcon()
                
            case .randomGame:
                Settings.userInterfaceFeatures.randomGame.useCollection = false
                
            case .touchVibration:
                Settings.touchFeedbackFeatures.touchVibration.strength = 1.0
                Settings.touchFeedbackFeatures.touchVibration.buttonsEnabled = true
                Settings.touchFeedbackFeatures.touchVibration.sticksEnabled = true
                Settings.touchFeedbackFeatures.touchVibration.releaseEnabled = true
                
            case .touchAudio:
                Settings.touchFeedbackFeatures.touchAudio.sound = .tock
                Settings.touchFeedbackFeatures.touchAudio.useGameVolume = true
                Settings.touchFeedbackFeatures.touchAudio.buttonVolume = 1.0
                
            case .touchOverlay:
                Settings.touchFeedbackFeatures.touchOverlay.themed = true
                Settings.touchFeedbackFeatures.touchOverlay.overlayColor = .white
                Settings.touchFeedbackFeatures.touchOverlay.style = .bubble
                Settings.touchFeedbackFeatures.touchOverlay.opacity = 1.0
                Settings.touchFeedbackFeatures.touchOverlay.size = 1.0
                
            case .skinDebug:
                Settings.advancedFeatures.skinDebug.isOn = false
                Settings.advancedFeatures.skinDebug.skinEnabled = false
                Settings.advancedFeatures.skinDebug.traitOverride = false
                Settings.advancedFeatures.skinDebug.device = Settings.advancedFeatures.skinDebug.defaultDevice
                Settings.advancedFeatures.skinDebug.displayType = Settings.advancedFeatures.skinDebug.defaultDisplayType
                Settings.advancedFeatures.skinDebug.useAlt = false
                Settings.advancedFeatures.skinDebug.hasAlt = false
                
            case .allFeatures:
                break
            }
        }
    }
}
