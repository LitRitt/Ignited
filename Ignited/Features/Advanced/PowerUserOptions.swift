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
    @Option(name: "Import Database",
            description: "This imports a legacy Ignited or Delta games database. The current database will be backed up.",
            //attributes: [.hidden(when: {SharedSettings.numberOfGames > 0 || Settings.legacyDatabaseHasBeenImported})],
            attributes: [.hidden(when: {SharedSettings.numberOfGames > 5})],
            detailView: { _ in
        Button("Import Legacy Database") {
            importLegacyDatabase()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.accentColor)
        .displayInline()
    })
    var importLegacyDatabase: String = ""
    
    @Option(name: "Repair Games",
            description: "Attempts to find and repair any missing games in the app's database.",
            attributes: [.hidden(when: {false})],
            detailView: { _ in
        Button("Repair Games") {
            fixGameCollections()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.accentColor)
        .displayInline()
    })
    var fixGameCollections: String = ""
    
    @Option(name: "Repair Save States",
            description: "Attempts to find and repair any missing save states in the app's database.",
            attributes: [.hidden(when: {false})],
            detailView: { _ in
        Button("Repair Save States") {
            fixSaveStates()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.accentColor)
        .displayInline()
    })
    var fixSaveStates: String = ""
    
    @Option(name: "Repair Skins",
            description: "Attempts to find and repair any missing skins.",
            attributes: [.hidden(when: {false})],
            detailView: { _ in
        Button("Repair Skins") {
            fixDeltaSkins()
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.accentColor)
        .displayInline()
    })
    var fixDeltaSkins: String = ""
    
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
    
    @Option(name: "Reset Build Counter",
            description: "This will force update actions, such as repairs, to be taken next app launch.",
            attributes: [.hidden(when: {true})],
            detailView: { _ in
        Button("Reset Build Counter") {
            Settings.buildNumber = 1
        }
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(.red)
        .displayInline()
    })
    var resetBuildCounter: String = ""
}

extension PowerUserOptions
{
    static func resetBuildCounter()
    {
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledToast()
            return
        }
        
        Settings.buildNumber = 1
        
        ToastView.show(NSLocalizedString("Successfully reset build counter", comment: ""), onEdge: .bottom, duration: 3.0)
    }
    
    static func fixGameCollections()
    {
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledToast()
            return
        }
        
        DatabaseManager.shared.repairGameCollections(repairAll: true)
        
        ToastView.show(NSLocalizedString("Attempted to repair games", comment: ""), onEdge: .bottom, duration: 3.0)
    }
    
    static func fixSaveStates()
    {
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledToast()
            return
        }
        
        DatabaseManager.shared.repairSaveStates()
        
        ToastView.show(NSLocalizedString("Attempted to repair save states", comment: ""), onEdge: .bottom, duration: 3.0)
    }
    
    static func fixDeltaSkins()
    {
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledToast()
            return
        }
        
        DatabaseManager.shared.repairSaveStates()
        
        ToastView.show(NSLocalizedString("Attempted to repair skins", comment: ""), onEdge: .bottom, duration: 3.0)
    }

    static func clearAutoSaveStates()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledToast()
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
                            
                            // All toasts show on main thread
                            ToastView.show(NSLocalizedString("Successfully Cleared All Auto Save States", comment: ""), in: topViewController.view, onEdge: .bottom, duration: 3.0)
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
            self.showFeatureDisabledToast()
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
                    
                    // All toasts show on main thread
                    ToastView.show(NSLocalizedString("Successfully Reset All Artwork", comment: ""), in: topViewController.view, onEdge: .bottom, duration: 3.0)
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
                self.showFeatureDisabledToast()
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
                
                ToastView.show(NSLocalizedString("Successfully Reset All Feature Settings", comment: ""), in: topViewController.view, onEdge: .bottom, duration: 3.0)
            })
            
        default:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                feature.resetSettings()
                
                ToastView.show(NSLocalizedString("Successfully Reset Feature Settings", comment: ""), in: topViewController.view, onEdge: .bottom, duration: 3.0)
            })
        }
        
        alertController.popoverPresentationController?.sourceView = topViewController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(resetAction)
        alertController.addAction(.cancel)
        
        topViewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showFeatureDisabledToast()
    {
        ToastView.show(NSLocalizedString("Enable Power User Tools to use this feature", comment: ""), onEdge: .bottom)
    }
}

extension PowerUserOptions
{
    enum DatabaseFile: String, CaseIterable
    {
        case db = "sqlite"
        case wal = "sqlite-wal"
        case shm = "sqlite-smh"
        
        var fileExtension: String {
            return self.rawValue
        }
    }
    
    static func importLegacyDatabase(skipBackup: Bool = false)
    {
        // Backup current database
        for ext in DatabaseFile.allCases {
            let fileURL = DatabaseManager.defaultDirectoryURL().appending(component: "Ignited").appendingPathExtension(ext.fileExtension)
            let backupURL = DatabaseManager.backupDirectoryURL.appending(component: "Ignited").appendingPathExtension(ext.fileExtension)
            if FileManager.default.fileExists(atPath: fileURL.path()) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    try data.write(to: backupURL)
                } catch {
                    if ext == .shm || skipBackup {
                        continue
                    } else {
                        Logger.database.error("Failed to import legacy database. Could not backup the current database's .\(ext.fileExtension, privacy: .public) file.")
                        return
                    }
                }
            }
        }
        
        // Import legacy database
        for ext in DatabaseFile.allCases {
            let fileURL = DatabaseManager.defaultDirectoryURL().appending(component: "Delta").appendingPathExtension(ext.fileExtension)
            let newURL = DatabaseManager.defaultDirectoryURL().appending(component: "Ignited").appendingPathExtension(ext.fileExtension)
            if FileManager.default.fileExists(atPath: fileURL.path()) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    try data.write(to: newURL)
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    if ext == .shm {
                        continue
                    } else {
                        Logger.database.error("Failed to import legacy database. Could not import the legacy database's .\(ext.fileExtension, privacy: .public) file.")
                        return
                    }
                }
            }
        }
        
        if !skipBackup
        {
            ToastView.show(NSLocalizedString("Successfully imported legacy database", comment: ""), detailText: NSLocalizedString("Restart the app for changes to take effect", comment: ""), onEdge: .bottom, duration: 10.0)
        }
        
        Logger.database.info("Successfully imported legacy database.")
        Settings.legacyDatabaseHasBeenImported = true
        Settings.legacyDatabaseHasBeenRepaired = false
    }
    
    static func importLegacyDatabasePrompt()
    {
        guard let topViewController = UIApplication.shared.topViewController() else { return }
        
        guard Settings.advancedFeatures.powerUser.isEnabled else {
            self.showFeatureDisabledToast()
            return
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("Import Legacy Database?", comment: ""), message: NSLocalizedString("This will backup the current database files for the app and replace them with legacy database files if they're available from a previous beta installation.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = topViewController.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(UIAlertAction(title: "Import", style: .destructive, handler: { (action) in
            importLegacyDatabase()
        }))
        
        alertController.addAction(.cancel)
        
        topViewController.present(alertController, animated: true, completion: nil)
    }
}
    
extension PowerUserOptions
{
    enum Feature: Int, CaseIterable
    {
        // SNES
        case snesInvalidVRAM
        // GB
        case gbPalettes
        // N64
        case n64OpenGLES3
        // Gameplay
        case pauseMenu
        case gameScreenshot
        case gameAudio
        case saveStateRewind
        case fastForward
        case quickSettings
        case swipeGestures
        // Standard Skins
        case styleAndColor
        case gameScreen
        case inputsAndLayout
        // Controllers
        case skin
        case backgroundBlur
        case controller
        // Library
        case importOptions
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
        case lowPower
        case allFeatures
        
        func resetSettings()
        {
            switch self
            {
            case .gbPalettes:
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
                
            case .snesInvalidVRAM:
                Settings.snesFeatures.allowInvalidVRAMAccess.enabledGames = []
                
            case .n64OpenGLES3:
                Settings.n64Features.openGLES2.enabledGames = []
                
            case .pauseMenu:
                Settings.gameplayFeatures.pauseMenu.buttonOrder = ["Save State", "Load State", "Restart", "Screenshot", "Status Bar", "Sustain Buttons", "Rewind", "Fast Forward", "Microphone", "Rotation Lock", "Palettes", "Quick Settings", "Backgroud Blur", "Overscan Editor", "Cheat Codes", "Alt Skin", "Debug Mode"]
                
            case .gameScreenshot:
                Settings.gameplayFeatures.screenshots.saveLocation = .photos
                Settings.gameplayFeatures.screenshots.size = .x5
                
            case .gameAudio:
                Settings.gameplayFeatures.gameAudio.volume = 1.0
                Settings.gameplayFeatures.gameAudio.respectSilent = true
                Settings.gameplayFeatures.gameAudio.playOver = true
                
            case .saveStateRewind:
                Settings.gameplayFeatures.rewind.interval = 15
                Settings.gameplayFeatures.rewind.maxStates = Settings.proFeaturesEnabled ? 30 : 4
                Settings.gameplayFeatures.rewind.keepStates = Settings.proFeaturesEnabled ? true : false
                
            case .fastForward:
                Settings.gameplayFeatures.fastForward.speed = 3.0
                Settings.gameplayFeatures.fastForward.mode = .toggle
                
            case .quickSettings:
                Settings.gameplayFeatures.quickSettings.shakeToOpen = false
                Settings.gameplayFeatures.quickSettings.buttonReplacement = nil
                
            case .swipeGestures:
                Settings.controllerFeatures.swipeGestures.up = ActionInput.statusBar
                Settings.controllerFeatures.swipeGestures.down = ActionInput.quickSave
                Settings.controllerFeatures.swipeGestures.left = ActionInput.screenshot
                Settings.controllerFeatures.swipeGestures.right = ActionInput.fastForward
                
            case .styleAndColor:
                Settings.standardSkinFeatures.styleAndColor.style = .filled
                Settings.standardSkinFeatures.styleAndColor.color = .auto
                Settings.standardSkinFeatures.styleAndColor.customColor = .orange
                Settings.standardSkinFeatures.styleAndColor.customColorSecondary = .white
                Settings.standardSkinFeatures.styleAndColor.translucentInputs = true
                Settings.standardSkinFeatures.styleAndColor.shadows = true
                Settings.standardSkinFeatures.styleAndColor.shadowOpacity = 0.5
                
            case .gameScreen:
                Settings.standardSkinFeatures.gameScreen.style = .floatingRounded
                Settings.standardSkinFeatures.gameScreen.landscapeSize = .fitInputs
                Settings.standardSkinFeatures.gameScreen.dsTopScreenSize = 0.5
                Settings.standardSkinFeatures.gameScreen.unsafeArea = 40
                
            case .inputsAndLayout:
                Settings.standardSkinFeatures.inputsAndLayout.customButton1 = Settings.proFeaturesEnabled ? .fastForward : .null
                Settings.standardSkinFeatures.inputsAndLayout.customButton2 = Settings.proFeaturesEnabled ? .quickSave : .null
                Settings.standardSkinFeatures.inputsAndLayout.dsScreenSwap = Settings.proFeaturesEnabled ? true : false
                Settings.standardSkinFeatures.inputsAndLayout.dsLayout = .comfortable
                Settings.standardSkinFeatures.inputsAndLayout.directionalInputType = .dPad
                Settings.standardSkinFeatures.inputsAndLayout.abxyLayout = .nintendo
                Settings.standardSkinFeatures.inputsAndLayout.n64FaceLayout = .none
                Settings.standardSkinFeatures.inputsAndLayout.n64ShoulderLayout = .none
                Settings.standardSkinFeatures.inputsAndLayout.genesisFaceLayout = .button3
                Settings.standardSkinFeatures.inputsAndLayout.extendedEdges = 10
                Settings.standardSkinFeatures.inputsAndLayout.splitViewPortraitSize = 0.3
                Settings.standardSkinFeatures.inputsAndLayout.splitViewLandscapeSize = 0.4
                
            case .skin:
                Settings.controllerFeatures.skin.opacity = 0.7
                Settings.controllerFeatures.skin.colorMode = .none
                Settings.controllerFeatures.skin.backgroundColor = .black
                
            case .backgroundBlur:
                Settings.controllerFeatures.backgroundBlur.style = .systemThin
                Settings.controllerFeatures.backgroundBlur.brightness = .auto
                Settings.controllerFeatures.backgroundBlur.tintColor = .theme
                Settings.controllerFeatures.backgroundBlur.customColor = .orange
                Settings.controllerFeatures.backgroundBlur.tintOpacity = 0.5
                Settings.controllerFeatures.backgroundBlur.maintainAspect = true
                
            case .controller:
                Settings.controllerFeatures.controller.hideSkin = true
                Settings.controllerFeatures.controller.triggerDeadzone = 0.15
                
            case .importOptions:
                Settings.libraryFeatures.importing.automated = true
                Settings.libraryFeatures.importing.sanitize = true
                Settings.libraryFeatures.importing.popup = true
                
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
                Settings.libraryFeatures.artwork.useScreenshots = false
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
                Settings.userInterfaceFeatures.toasts.altSkin = false
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
                Settings.touchFeedbackFeatures.touchAudio.sound = .snap
                Settings.touchFeedbackFeatures.touchAudio.useGameVolume = true
                Settings.touchFeedbackFeatures.touchAudio.buttonVolume = 1.0
                
            case .touchOverlay:
                Settings.touchFeedbackFeatures.touchOverlay.color = .theme
                Settings.touchFeedbackFeatures.touchOverlay.customColor = .orange
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
                
            case .lowPower:
                Settings.advancedFeatures.lowBattery.lowLevel = 0.10
                Settings.advancedFeatures.lowBattery.criticalLevel = 0.05
                
            case .allFeatures:
                break
            }
        }
    }
}
