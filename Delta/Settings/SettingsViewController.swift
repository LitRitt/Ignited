//
//  SettingsViewController.swift
//  Delta
//
//  Created by Riley Testut on 9/4/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit
import SafariServices
import SwiftUI

import DeltaCore

import Roxas

private extension SettingsViewController
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
        // Games Collestion
        case artworkCustomization
        case animatedArtwork
        case favoriteGames
        // User Interface
        case toastNotifications
        case statusBar
        case themeColor
        case appIcon
        // Touch Feedback
        case touchVibration
        case touchAudio
        case touchOverlay
        // Advanced
        case skinDebug
        case allFeatures
    }
    
    enum Section: Int, CaseIterable
    {
        case patreon
        case syncing
        case cores
        case features
        case controllers
        case controllerSkins
        case shortcuts
        case skinDownloads
        case resourceLinks
        case credits
        case updates
    }
    
    enum Segue: String
    {
        case controllers = "controllersSegue"
        case controllerSkins = "controllerSkinsSegue"
        case dsSettings = "dsSettingsSegue"
    }
    
    enum FeaturesRow: Int, CaseIterable
    {
        case gameplay
        case controllerSkins
        case gamesCollection
        case userInterface
        case touchFeedback
        case advanced
    }
    
    enum SkinDownloadsRow: Int, CaseIterable
    {
        case classicSkins
        case litDesign
        case skinGenerator
        case deltaSkins
        case skins4Delta
    }

    enum SyncingRow: Int, CaseIterable
    {
        case service
        case status
    }
    
    enum CreditsRow: Int, CaseIterable
    {
        case developer
        case contributors
        case softwareLicenses
    }
    
    enum ResourceLinksRow: Int, CaseIterable
    {
        case romPatcher
        case saveConverter
    }
    
    enum PatreonRow: Int, CaseIterable
    {
        case patreonLink
        case patrons
    }
    
    enum CoresRow: Int, CaseIterable
    {
        case n64
        case gbc
        case ds
    }
}

class SettingsViewController: UITableViewController
{
    @IBOutlet private var versionLabel: UILabel!
    
    @IBOutlet private var syncingServiceLabel: UILabel!
    
    private var selectionFeedbackGenerator: UISelectionFeedbackGenerator?
    
    private var previousSelectedRowIndexPath: IndexPath?
    
    private var syncingConflictsCount = 0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.settingsDidChange(with:)), name: Settings.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.externalGameControllerDidConnect(_:)), name: .externalGameControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.externalGameControllerDidDisconnect(_:)), name: .externalGameControllerDidDisconnect, object: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let version = Bundle.main.versionNumber
        {
            self.versionLabel.text = NSLocalizedString(String(format: "Ignited v%@", version), comment: "Ignited Version")
        }
        else
        {
            self.versionLabel.text = NSLocalizedString("Ignited", comment: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let indexPath = self.previousSelectedRowIndexPath
        {
            if indexPath.section == Section.controllers.rawValue
            {
                // Update and temporarily re-select selected row.
                self.tableView.reloadSections(IndexSet(integer: Section.controllers.rawValue), with: .none)
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            }
            
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        self.update()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard
            let identifier = segue.identifier,
            let segueType = Segue(rawValue: identifier),
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell)
        else { return }
        
        self.previousSelectedRowIndexPath = indexPath
        
        switch segueType
        {
        case Segue.controllers:
            let controllersSettingsViewController = segue.destination as! ControllersSettingsViewController
            controllersSettingsViewController.playerIndex = indexPath.row
            
        case Segue.controllerSkins:
            let preferredControllerSkinsViewController = segue.destination as! PreferredControllerSkinsViewController
            
            let system = System.registeredSystems[indexPath.row]
            preferredControllerSkinsViewController.system = system
            
        case Segue.dsSettings: break
        }
    }
}

private extension SettingsViewController
{
    func update()
    {
        self.syncingServiceLabel.text = Settings.syncingService?.localizedName
        
        do
        {
            let records = try SyncManager.shared.recordController?.fetchConflictedRecords() ?? []
            self.syncingConflictsCount = records.count
        }
        catch
        {
            print(error)
        }
        
        self.view.tintColor = UIColor.themeColor
        
        self.tableView.reloadData()
    }
    
    func isSectionHidden(_ section: Section) -> Bool
    {
        switch section
        {
        default: return false
        }
    }
}

private extension SettingsViewController
{
    func openWebsite(site: String)
    {
        let safariURL = URL(string: site)!
        let safariViewController = SFSafariViewController(url: safariURL)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func openHomePage()
    {
        let safariURL = URL(string: "https://litritt.com/")!
        let safariViewController = SFSafariViewController(url: safariURL)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func showUpdates()
    {
        let hostingController = UpdatesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showContributors()
    {
        let hostingController = ContributorsView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showPatrons()
    {
        let hostingController = PatronsView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showGameplayFeatures()
    {
        let hostingController = GameplayFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showControllerSkinFeatures()
    {
        let hostingController = ControllerSkinFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showGamesCollectionFeatures()
    {
        let hostingController = GamesCollectionFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showUserInterfaceFeatures()
    {
        let hostingController = UserInterfaceFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showTouchFeedbackFeatures()
    {
        let hostingController = TouchFeedbackFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showAdvancedFeatures()
    {
        let hostingController = AdvancedFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showN64Features()
    {
        let hostingController = N64FeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func showGBCFeatures()
    {
        let hostingController = GBCFeaturesView.makeViewController()
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func resetBuildCounter()
    {
        Settings.lastUpdateShown = 1
    }
    
    func clearAutoSaveStates()
    {
        let alertController = UIAlertController(title: NSLocalizedString("⚠️ Clear States? ⚠️", comment: ""), message: NSLocalizedString("This will delete all auto save states from every game. The auto-load save states feature relies on these auto save states to resume your game where you left off. Deleting them can be useful to reduce the size of your Sync backup.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
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
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func resetAllArtwork()
    {
        let alertController = UIAlertController(title: NSLocalizedString("⚠️ Reset Artwork? ⚠️", comment: ""), message: NSLocalizedString("This will reset the artwork for every game to the one provided by the games database used by Ignited. Do not proceed if you do not have backup of your custom artworks.", comment: ""), preferredStyle: .alert)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
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
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateAppIcon()
    {
        let currentIcon = UIApplication.shared.alternateIconName
        
        if UserInterfaceFeatures.shared.appIcon.isEnabled
        {
            if UserInterfaceFeatures.shared.appIcon.useTheme
            {
                guard UserInterfaceFeatures.shared.theme.isEnabled else
                {
                    if currentIcon != nil { UIApplication.shared.setAlternateIconName(nil) }
                    return
                }
                
                let themeIcon = UserInterfaceFeatures.shared.theme.accentColor
                
                switch themeIcon
                {
                case .orange: if currentIcon != nil { UIApplication.shared.setAlternateIconName(nil) }
                default: if currentIcon != themeIcon.assetName { UIApplication.shared.setAlternateIconName(themeIcon.assetName) }
                }
            }
            else
            {
                let altIcon = UserInterfaceFeatures.shared.appIcon.alternateIcon
                
                switch altIcon
                {
                case .normal: if currentIcon != nil { UIApplication.shared.setAlternateIconName(nil) }
                default: if currentIcon != altIcon.assetName { UIApplication.shared.setAlternateIconName(altIcon.assetName) }
                }
            }
        }
        else
        {
            if currentIcon != nil { UIApplication.shared.setAlternateIconName(nil) }
        }
    }
    
    func resetFeature(_ feature: Feature)
    {
        let resetGameboyPalettes = {
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
        }
        
        let resetN64Graphics = {
            N64Features.shared.n64graphics.graphicsAPI = .openGLES2
        }
        
        let resetArtworkCustomization = {
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
        }
        
        let resetAnimatedArtwork = {
            GamesCollectionFeatures.shared.animation.animationSpeed = 1.0
            GamesCollectionFeatures.shared.animation.animationPause = 0
            GamesCollectionFeatures.shared.animation.animationMaxLength = 30
        }
        
        let resetFavoriteGames = {
            GamesCollectionFeatures.shared.favorites.favoriteSort = true
            GamesCollectionFeatures.shared.favorites.favoriteHighlight = true
            GamesCollectionFeatures.shared.favorites.favoriteColor = Color(red: 255/255, green: 234/255, blue: 0/255)
            GamesCollectionFeatures.shared.favorites.highlightIntensity = 0.7
        }
        
        let resetGameScreenshot = {
            GameplayFeatures.shared.screenshots.saveToFiles = true
            GameplayFeatures.shared.screenshots.saveToPhotos = false
            GameplayFeatures.shared.screenshots.playCountdown = false
            GameplayFeatures.shared.screenshots.size = nil
        }
        
        let resetGameAudio = {
            GameplayFeatures.shared.gameAudio.volume = 1.0
            GameplayFeatures.shared.gameAudio.respectSilent = true
            GameplayFeatures.shared.gameAudio.playOver = true
        }
        
        let resetSaveStateRewind = {
            GameplayFeatures.shared.rewind.interval = 15
            GameplayFeatures.shared.rewind.maxStates = 30
            GameplayFeatures.shared.rewind.keepStates = true
        }
        
        let resetFastForward = {
            GameplayFeatures.shared.fastForward.speed = 3.0
            GameplayFeatures.shared.fastForward.toggle = true
            GameplayFeatures.shared.fastForward.prompt = false
            GameplayFeatures.shared.fastForward.slowmo = false
            GameplayFeatures.shared.fastForward.unsafe = false
        }
        
        let resetQuickSettings = {
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
        }
        
        let resetToastNotifications = {
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
        }
        
        let resetStatusBar = {
            UserInterfaceFeatures.shared.statusBar.isOn = false
            UserInterfaceFeatures.shared.statusBar.useToggle = false
            UserInterfaceFeatures.shared.statusBar.style = .light
        }
        
        let resetThemeColor = {
            UserInterfaceFeatures.shared.theme.accentColor = .orange
            UserInterfaceFeatures.shared.theme.useCustom = false
            UserInterfaceFeatures.shared.theme.customColor = Color(red: 253/255, green: 110/255, blue: 0/255)
        }
        
        let resetAppIcon = {
            UserInterfaceFeatures.shared.appIcon.useTheme = true
            UserInterfaceFeatures.shared.appIcon.alternateIcon = .normal
        }
        
        let resetSkinCustomization = {
            ControllerSkinFeatures.shared.skinCustomization.opacity = 0.7
            ControllerSkinFeatures.shared.skinCustomization.alwaysShow = false
            ControllerSkinFeatures.shared.skinCustomization.matchTheme = false
            ControllerSkinFeatures.shared.skinCustomization.backgroundColor = Color(red: 0/255, green: 0/255, blue: 0/255)
        }
        
        let resetBackgroundBlur = {
            ControllerSkinFeatures.shared.backgroundBlur.blurBackground = true
            ControllerSkinFeatures.shared.backgroundBlur.blurAirPlay = true
            ControllerSkinFeatures.shared.backgroundBlur.blurAspect = true
            ControllerSkinFeatures.shared.backgroundBlur.blurOverride = false
            ControllerSkinFeatures.shared.backgroundBlur.blurStrength = 1.0
            ControllerSkinFeatures.shared.backgroundBlur.blurBrightness = 0.0
        }
        
        let resetController = {
            ControllerSkinFeatures.shared.controller.triggerDeadzone = 0.15
        }
        
        let resetTouchVibration = {
            TouchFeedbackFeatures.shared.touchVibration.strength = 1.0
            TouchFeedbackFeatures.shared.touchVibration.buttonsEnabled = true
            TouchFeedbackFeatures.shared.touchVibration.sticksEnabled = true
            TouchFeedbackFeatures.shared.touchVibration.releaseEnabled = true
        }
        
        let resetTouchAudio = {
            TouchFeedbackFeatures.shared.touchAudio.sound = nil
        }
        
        let resetTouchOverlay = {
            TouchFeedbackFeatures.shared.touchOverlay.themed = true
            TouchFeedbackFeatures.shared.touchOverlay.overlayColor = Color(red: 255/255, green: 255/255, blue: 255/255)
            TouchFeedbackFeatures.shared.touchOverlay.opacity = 0.7
            TouchFeedbackFeatures.shared.touchOverlay.size = 1.0
        }
        
        let resetSkinDebug = {
            AdvancedFeatures.shared.skinDebug.isOn = false
            AdvancedFeatures.shared.skinDebug.skinEnabled = false
            AdvancedFeatures.shared.skinDebug.device = nil
            AdvancedFeatures.shared.skinDebug.useAlt = false
            AdvancedFeatures.shared.skinDebug.hasAlt = false
        }
        
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
        case .gameboyPalettes:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetGameboyPalettes()
            })
            
        case .n64Graphics:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetN64Graphics()
            })
            
        case .artworkCustomization:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetArtworkCustomization()
            })
            
        case .animatedArtwork:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetAnimatedArtwork()
            })
            
        case .favoriteGames:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetFavoriteGames()
            })
            
        case .gameScreenshot:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetGameScreenshot()
            })
            
        case .gameAudio:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetGameAudio()
            })
            
        case .saveStateRewind:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetSaveStateRewind()
            })
            
        case .fastForward:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetFastForward()
            })
            
        case .quickSettings:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetQuickSettings()
            })
            
        case .toastNotifications:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetToastNotifications()
            })
            
        case .statusBar:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetStatusBar()
            })
            
        case .themeColor:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetThemeColor()
            })
            
        case .appIcon:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetAppIcon()
            })
            
        case .skinCustomization:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetSkinCustomization()
            })
            
        case .backgroundBlur:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetBackgroundBlur()
            })
            
        case .controller:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetController()
            })
            
        case .touchVibration:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetTouchVibration()
            })
            
        case .touchAudio:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetTouchAudio()
            })
            
        case .touchOverlay:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetTouchOverlay()
            })
            
        case .skinDebug:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetSkinDebug()
            })
            
        case .allFeatures:
            resetAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                resetGameboyPalettes()
                resetN64Graphics()
                resetArtworkCustomization()
                resetAnimatedArtwork()
                resetFavoriteGames()
                resetGameScreenshot()
                resetGameAudio()
                resetSaveStateRewind()
                resetFastForward()
                resetQuickSettings()
                resetToastNotifications()
                resetStatusBar()
                resetThemeColor()
                resetAppIcon()
                resetSkinCustomization()
                resetBackgroundBlur()
                resetController()
                resetTouchVibration()
                resetTouchAudio()
                resetTouchOverlay()
                resetSkinDebug()
            })
        }
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = []
        
        alertController.addAction(resetAction)
        alertController.addAction(.cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

private extension SettingsViewController
{
    @objc func settingsDidChange(with notification: Notification)
    {
        guard let settingsName = notification.userInfo?[Settings.NotificationUserInfoKey.name] as? Settings.Name else { return }
        
        switch settingsName
        {
        case .syncingService:
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            
            self.tableView.reloadSections(IndexSet(integer: Section.syncing.rawValue), with: .none)
            
            let syncingServiceIndexPath = IndexPath(row: SyncingRow.service.rawValue, section: Section.syncing.rawValue)
            if selectedIndexPath == syncingServiceIndexPath
            {
                self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
            }
            
        case AdvancedFeatures.shared.powerUser.$clearAutoSaves.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    AdvancedFeatures.shared.powerUser.clearAutoSaves = false
                    self.clearAutoSaveStates()
                }
            }
            
        case AdvancedFeatures.shared.powerUser.$resetArtwork.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    AdvancedFeatures.shared.powerUser.resetArtwork = false
                    self.resetAllArtwork()
                }
            }
            
        case AdvancedFeatures.shared.powerUser.$resetBuildCounter.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    AdvancedFeatures.shared.powerUser.resetBuildCounter = false
                    self.resetBuildCounter()
                }
            }
            
        case GBCFeatures.shared.palettes.$resetGameboyPalettes.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GBCFeatures.shared.palettes.resetGameboyPalettes = false
                    self.resetFeature(.gameboyPalettes)
                }
            }
            
        case N64Features.shared.n64graphics.$resetN64Graphics.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    N64Features.shared.n64graphics.resetN64Graphics = false
                    self.resetFeature(.n64Graphics)
                }
            }
            
        case GamesCollectionFeatures.shared.artwork.$resetArtworkCustomization.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GamesCollectionFeatures.shared.artwork.resetArtworkCustomization = false
                    self.resetFeature(.artworkCustomization)
                }
            }
            
        case GamesCollectionFeatures.shared.animation.$resetAnimatedArtwork.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GamesCollectionFeatures.shared.animation.resetAnimatedArtwork = false
                    self.resetFeature(.animatedArtwork)
                }
            }
            
        case GamesCollectionFeatures.shared.favorites.$resetFavoriteGames.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GamesCollectionFeatures.shared.favorites.resetFavoriteGames = false
                    self.resetFeature(.favoriteGames)
                }
            }
            
        case GameplayFeatures.shared.screenshots.$resetGameScreenshots.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GameplayFeatures.shared.screenshots.resetGameScreenshots = false
                    self.resetFeature(.gameScreenshot)
                }
            }
            
        case GameplayFeatures.shared.gameAudio.$resetGameAudio.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GameplayFeatures.shared.gameAudio.resetGameAudio = false
                    self.resetFeature(.gameAudio)
                }
            }
            
        case GameplayFeatures.shared.rewind.$resetSaveStateRewind.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GameplayFeatures.shared.rewind.resetSaveStateRewind = false
                    self.resetFeature(.saveStateRewind)
                }
            }
            
        case GameplayFeatures.shared.fastForward.$resetFastForward.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GameplayFeatures.shared.fastForward.resetFastForward = false
                    self.resetFeature(.fastForward)
                }
            }
            
        case GameplayFeatures.shared.quickSettings.$resetQuickSettings.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    GameplayFeatures.shared.quickSettings.resetQuickSettings = false
                    self.resetFeature(.quickSettings)
                }
            }
            
        case UserInterfaceFeatures.shared.toasts.$resetToastNotifications.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    UserInterfaceFeatures.shared.toasts.resetToastNotifications = false
                    self.resetFeature(.toastNotifications)
                }
            }
            
        case UserInterfaceFeatures.shared.statusBar.$resetStatusBar.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    UserInterfaceFeatures.shared.statusBar.resetStatusBar = false
                    self.resetFeature(.statusBar)
                }
            }
            
        case UserInterfaceFeatures.shared.theme.$resetThemeColor.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    UserInterfaceFeatures.shared.theme.resetThemeColor = false
                    self.resetFeature(.themeColor)
                }
            }
            
        case UserInterfaceFeatures.shared.appIcon.$resetAppIcon.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    UserInterfaceFeatures.shared.appIcon.resetAppIcon = false
                    self.resetFeature(.appIcon)
                }
            }
            
        case ControllerSkinFeatures.shared.skinCustomization.$resetSkinCustomization.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    ControllerSkinFeatures.shared.skinCustomization.resetSkinCustomization = false
                    self.resetFeature(.skinCustomization)
                }
            }
            
        case ControllerSkinFeatures.shared.backgroundBlur.$resetBackgroundBlur.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    ControllerSkinFeatures.shared.backgroundBlur.resetBackgroundBlur = false
                    self.resetFeature(.backgroundBlur)
                }
            }
            
        case ControllerSkinFeatures.shared.controller.$resetController.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    ControllerSkinFeatures.shared.controller.resetController = false
                    self.resetFeature(.controller)
                }
            }
            
        case TouchFeedbackFeatures.shared.touchVibration.$resetTouchVibration.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    TouchFeedbackFeatures.shared.touchVibration.resetTouchVibration = false
                    self.resetFeature(.touchVibration)
                }
            }
            
        case TouchFeedbackFeatures.shared.touchAudio.$resetTouchAudio.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    TouchFeedbackFeatures.shared.touchAudio.resetTouchAudio = false
                    self.resetFeature(.touchAudio)
                }
            }
            
        case TouchFeedbackFeatures.shared.touchOverlay.$resetTouchOverlay.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    TouchFeedbackFeatures.shared.touchOverlay.resetTouchOverlay = false
                    self.resetFeature(.touchOverlay)
                }
            }
            
        case AdvancedFeatures.shared.skinDebug.$resetSkinDebug.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    AdvancedFeatures.shared.skinDebug.resetSkinDebug = false
                    self.resetFeature(.skinDebug)
                }
            }
            
        case AdvancedFeatures.shared.powerUser.$resetAllSettings.settingsKey:
            guard let value = notification.userInfo?[Settings.NotificationUserInfoKey.value] as? Bool else { break }
            if value
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    AdvancedFeatures.shared.powerUser.resetAllSettings = false
                    self.resetFeature(.allFeatures)
                }
            }
            
        case UserInterfaceFeatures.shared.appIcon.settingsKey, UserInterfaceFeatures.shared.appIcon.$useTheme.settingsKey, UserInterfaceFeatures.shared.theme.settingsKey, UserInterfaceFeatures.shared.theme.$accentColor.settingsKey:
            self.updateAppIcon()
            
        case UserInterfaceFeatures.shared.appIcon.$alternateIcon.settingsKey:
            UserInterfaceFeatures.shared.appIcon.useTheme = false
            self.updateAppIcon()
            
        default: break
        }
    }

    @objc func externalGameControllerDidConnect(_ notification: Notification)
    {
        self.tableView.reloadSections(IndexSet(integer: Section.controllers.rawValue), with: .none)
    }
    
    @objc func externalGameControllerDidDisconnect(_ notification: Notification)
    {
        self.tableView.reloadSections(IndexSet(integer: Section.controllers.rawValue), with: .none)
    }
}

extension SettingsViewController
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int
    {
        let section = Section(rawValue: sectionIndex)!
        switch section
        {
        case .controllers: return 4 // Temporarily hide other controller indexes until controller logic is finalized
        case .controllerSkins: return System.registeredSystems.count
        case .syncing: return SyncManager.shared.coordinator?.account == nil ? 1 : super.tableView(tableView, numberOfRowsInSection: sectionIndex)
        default:
            if isSectionHidden(section)
            {
                return 0
            }
            else
            {
                return super.tableView(tableView, numberOfRowsInSection: sectionIndex)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let section = Section(rawValue: indexPath.section)!
        switch section
        {
        case .controllers:
            if indexPath.row == Settings.localControllerPlayerIndex
            {
                cell.detailTextLabel?.text = UIDevice.current.name
            }
            else if let index = ExternalGameControllerManager.shared.connectedControllers.firstIndex(where: { $0.playerIndex == indexPath.row })
            {
                let controller = ExternalGameControllerManager.shared.connectedControllers[index]
                cell.detailTextLabel?.text = controller.name
            }
            else
            {
                cell.detailTextLabel?.text = nil
            }
            
        case .controllerSkins:
            cell.textLabel?.text = System.registeredSystems[indexPath.row].localizedName
                        
        case .syncing:
            switch SyncingRow.allCases[indexPath.row]
            {
            case .status:
                let cell = cell as! BadgedTableViewCell
                cell.badgeLabel.text = self.syncingConflictsCount.description
                cell.badgeLabel.isHidden = (self.syncingConflictsCount == 0)
                
            case .service: break
            }
            
        case .cores:
            let preferredCore = Settings.preferredCore(for: .ds)
            cell.detailTextLabel?.text = preferredCore?.metadata?.name.value ?? preferredCore?.name ?? NSLocalizedString("Unknown", comment: "")
            
        default: break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        let section = Section(rawValue: indexPath.section)!

        switch section
        {
        case .controllers: self.performSegue(withIdentifier: Segue.controllers.rawValue, sender: cell)
        case .controllerSkins: self.performSegue(withIdentifier: Segue.controllerSkins.rawValue, sender: cell)
        case .skinDownloads:
            switch SkinDownloadsRow.allCases[indexPath.row]
            {
            case .classicSkins: self.openWebsite(site: "https://litritt.com/ignited/classic-skins")
            case .litDesign: self.openWebsite(site: "https://design.litritt.com")
            case .skinGenerator: self.openWebsite(site: "https://generator.skins4delta.com")
            case .deltaSkins: self.openWebsite(site: "https://delta-skins.github.io")
            case .skins4Delta: self.openWebsite(site: "https://skins4delta.com")
            }
            
        case .features:
            switch FeaturesRow.allCases[indexPath.row]
            {
            case .gameplay: self.showGameplayFeatures()
            case .controllerSkins: self.showControllerSkinFeatures()
            case .gamesCollection: self.showGamesCollectionFeatures()
            case .userInterface: self.showUserInterfaceFeatures()
            case .touchFeedback: self.showTouchFeedbackFeatures()
            case .advanced: self.showAdvancedFeatures()
            }
            
        case .resourceLinks:
            switch ResourceLinksRow.allCases[indexPath.row]
            {
            case .romPatcher: self.openWebsite(site: "https://www.marcrobledo.com/RomPatcher.js/")
            case .saveConverter: self.openWebsite(site: "https://www.save-editor.com/tools/wse_ds_save_converter.html")
            }
            
        case .cores:
            switch CoresRow.allCases[indexPath.row]
            {
            case .gbc:
                self.showGBCFeatures()
            case .n64:
                self.showN64Features()
            case .ds:
                self.performSegue(withIdentifier: Segue.dsSettings.rawValue, sender: cell)
            }
            
        case .patreon:
            switch PatreonRow.allCases[indexPath.row]
            {
            case .patreonLink:
                let patreonURL = URL(string: "https://www.patreon.com/litritt")!
                
                UIApplication.shared.open(patreonURL, options: [:]) { (success) in
                    guard !success else { return }
                    
                    let patreonURL = URL(string: "https://www.patreon.com/litritt")!
                    
                    let safariViewController = SFSafariViewController(url: patreonURL)
                    safariViewController.preferredControlTintColor = UIColor.themeColor
                    self.present(safariViewController, animated: true, completion: nil)
                }
                
            case .patrons: self.showPatrons()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .credits:
            switch CreditsRow.allCases[indexPath.row]
            {
            case .developer: self.openHomePage()
            case .contributors: self.showContributors()
            case .softwareLicenses: break
            }
            
        case .updates: self.showUpdates()
            
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
        primary:
            switch Section(rawValue: indexPath.section)!
            {
            case .cores:
                let row = CoresRow(rawValue: indexPath.row)!
                switch row
                {
                case .n64:
                    // Left this code intact in case I need to hide things in the future
                    guard !AdvancedFeatures.shared.devMode.isEnabled else { break }
//                    return 0.0
                    break
                    
                default: break
                }
                
            default: break
            }
            
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let section = Section(rawValue: section)!
        guard !isSectionHidden(section) else { return nil }
        
        switch section
        {
        case .shortcuts where self.view.traitCollection.forceTouchCapability == .available: return NSLocalizedString("3D Touch", comment: "")
        default: return super.tableView(tableView, titleForHeaderInSection: section.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        let section = Section(rawValue: section)!
        
        if isSectionHidden(section)
        {
            return nil
        }
        else
        {
            return super.tableView(tableView, titleForFooterInSection: section.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        let section = Section(rawValue: section)!
        
        if isSectionHidden(section)
        {
            return 1
        }
        else
        {
            return super.tableView(tableView, heightForHeaderInSection: section.rawValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        let section = Section(rawValue: section)!
        
        if isSectionHidden(section)
        {
            return 1
        }
        else
        {
            return super.tableView(tableView, heightForFooterInSection: section.rawValue)
        }
    }
}
