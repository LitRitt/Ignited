//
//  Settings.swift
//  Delta
//
//  Created by Riley Testut on 8/23/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import Foundation

import DeltaCore
import Features
import MelonDSDeltaCore

import Roxas

extension Settings.NotificationUserInfoKey
{
    static let system: Settings.NotificationUserInfoKey = "system"
    static let traits: Settings.NotificationUserInfoKey = "traits"
    static let core: Settings.NotificationUserInfoKey = "core"
}

extension Settings.Name
{
    static let localControllerPlayerIndex: Settings.Name = "localControllerPlayerIndex"
    static let preferredControllerSkin: Settings.Name = "preferredControllerSkin"
    static let syncingService: Settings.Name = "syncingService"
    static let isAltJITEnabled: Settings.Name = "isAltJITEnabled"
}

extension Settings
{
    enum GameShortcutsMode: String
    {
        case recent
        case manual
    }
    
    typealias Name = SettingsName
    typealias NotificationUserInfoKey = SettingsUserInfoKey
    
    static let didChangeNotification = Notification.Name.settingsDidChange
}

struct Settings
{
    static func registerDefaults()
    {
        let defaults = [
            #keyPath(UserDefaults.lastUpdateShown): 1,
            #keyPath(UserDefaults.gameShortcutsMode): GameShortcutsMode.recent.rawValue,
            #keyPath(UserDefaults.sortSaveStatesByOldestFirst): false,
            #keyPath(UserDefaults.isAltJITEnabled): false,
            Settings.preferredCoreSettingsKey(for: .ds): MelonDS.core.identifier,
            GameplayFeatures.shared.autoLoad.settingsKey.rawValue: true,
            GameplayFeatures.shared.cheats.settingsKey.rawValue: true,
            GameplayFeatures.shared.fastForward.settingsKey.rawValue: true,
            GameplayFeatures.shared.gameAudio.settingsKey.rawValue: true,
            GameplayFeatures.shared.screenshots.settingsKey.rawValue: true,
            GameplayFeatures.shared.rewind.settingsKey.rawValue: false,
            GameplayFeatures.shared.quickSettings.settingsKey.rawValue: true,
            GamesCollectionFeatures.shared.artwork.settingsKey.rawValue: true,
            GamesCollectionFeatures.shared.animation.settingsKey.rawValue: true,
            GamesCollectionFeatures.shared.favorites.settingsKey.rawValue: true,
            UserInterfaceFeatures.shared.appIcon.settingsKey.rawValue: true,
            UserInterfaceFeatures.shared.theme.settingsKey.rawValue: true,
            UserInterfaceFeatures.shared.skins.settingsKey.rawValue: true,
            UserInterfaceFeatures.shared.statusBar.settingsKey.rawValue: false,
            UserInterfaceFeatures.shared.previews.settingsKey.rawValue: false,
            UserInterfaceFeatures.shared.toasts.settingsKey.rawValue: true,
            TouchFeedbackFeatures.shared.touchAudio.settingsKey.rawValue: false,
            TouchFeedbackFeatures.shared.touchOverlay.settingsKey.rawValue: true,
            TouchFeedbackFeatures.shared.touchVibration.settingsKey.rawValue: true,
            AdvancedFeatures.shared.skinDebug.settingsKey.rawValue: false,
            AdvancedFeatures.shared.powerUser.settingsKey.rawValue: false,
            AdvancedFeatures.shared.devMode.settingsKey.rawValue: false,
            GBCFeatures.shared.palettes.settingsKey.rawValue: true,
            N64Features.shared.n64graphics.settingsKey.rawValue: false
        ] as [String : Any]
        UserDefaults.standard.register(defaults: defaults)
    }
}

extension Settings
{
    /// Update
    static var lastUpdateShown: Int {
        set { UserDefaults.standard.lastUpdateShown = newValue }
        get { return UserDefaults.standard.lastUpdateShown }
    }
    
    /// Controllers
    static var localControllerPlayerIndex: Int? = 0 {
        didSet {
            guard self.localControllerPlayerIndex != oldValue else { return }
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.localControllerPlayerIndex])
        }
    }
    
    static var previousGameCollection: GameCollection? {
        set { UserDefaults.standard.previousGameCollectionIdentifier = newValue?.identifier }
        get {
            guard let identifier = UserDefaults.standard.previousGameCollectionIdentifier else { return nil }
            
            let predicate = NSPredicate(format: "%K == %@", #keyPath(GameCollection.identifier), identifier)
            
            let gameCollection = GameCollection.instancesWithPredicate(predicate, inManagedObjectContext: DatabaseManager.shared.viewContext, type: GameCollection.self)
            return gameCollection.first
        }
    }
    
    static var gameShortcutsMode: GameShortcutsMode {
        set { UserDefaults.standard.gameShortcutsMode = newValue.rawValue }
        get {
            let mode = GameShortcutsMode(rawValue: UserDefaults.standard.gameShortcutsMode) ?? .recent
            return mode
        }
    }
    
    static var gameShortcuts: [Game] {
        set {
            let identifiers = newValue.map { $0.identifier }
            UserDefaults.standard.gameShortcutIdentifiers = identifiers
            
            let shortcuts = newValue.map { UIApplicationShortcutItem(localizedTitle: $0.name, action: .launchGame(identifier: $0.identifier)) }
            
            DispatchQueue.main.async {
                UIApplication.shared.shortcutItems = shortcuts
            }
        }
        get {
            let identifiers = UserDefaults.standard.gameShortcutIdentifiers
            
            do
            {
                let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K IN %@", #keyPath(Game.identifier), identifiers)
                fetchRequest.returnsObjectsAsFaults = false
                
                let games = try DatabaseManager.shared.viewContext.fetch(fetchRequest).sorted(by: { (game1, game2) -> Bool in
                    let index1 = identifiers.firstIndex(of: game1.identifier)!
                    let index2 = identifiers.firstIndex(of: game2.identifier)!
                    return index1 < index2
                })
                
                return games
            }
            catch
            {
                print(error)
            }
            
            return []
        }
    }
    
    static var syncingService: SyncManager.Service? {
        get {
            guard let syncingService = UserDefaults.standard.syncingService else { return nil }
            return SyncManager.Service(rawValue: syncingService)
        }
        set {
            UserDefaults.standard.syncingService = newValue?.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.syncingService])
        }
    }
    
    static var sortSaveStatesByOldestFirst: Bool {
        set { UserDefaults.standard.sortSaveStatesByOldestFirst = newValue }
        get {
            let sortByOldestFirst = UserDefaults.standard.sortSaveStatesByOldestFirst
            return sortByOldestFirst
        }
    }
    
    static var isAltJITEnabled: Bool {
        get {
            let isAltJITEnabled = UserDefaults.standard.isAltJITEnabled
            return isAltJITEnabled
        }
        set {
            UserDefaults.standard.isAltJITEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltJITEnabled])
        }
    }
    
    static func preferredCore(for gameType: GameType) -> DeltaCoreProtocol?
    {
        let key = self.preferredCoreSettingsKey(for: gameType)
        
        let identifier = UserDefaults.standard.string(forKey: key)
        
        let core = System.allCores.first { $0.identifier == identifier }
        return core
    }
    
    static func setPreferredCore(_ core: DeltaCoreProtocol, for gameType: GameType)
    {
        Delta.register(core)
        
        let key = self.preferredCoreSettingsKey(for: gameType)
        
        UserDefaults.standard.set(core.identifier, forKey: key)
        NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: key, NotificationUserInfoKey.core: core])
    }
    
    static func preferredControllerSkin(for system: System, traits: DeltaCore.ControllerSkin.Traits) -> ControllerSkin?
    {
        guard let userDefaultsKey = self.preferredControllerSkinKey(for: system, traits: traits) else { return nil }
        
        let identifier = UserDefaults.standard.string(forKey: userDefaultsKey)
        
        do
        {
            // Attempt to load preferred controller skin if it exists
            
            let fetchRequest: NSFetchRequest<ControllerSkin> = ControllerSkin.fetchRequest()
            
            if let identifier = identifier
            {
                fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(ControllerSkin.gameType), system.gameType.rawValue, #keyPath(ControllerSkin.identifier), identifier)
                
                if let controllerSkin = try DatabaseManager.shared.viewContext.fetch(fetchRequest).first
                {
                    return controllerSkin
                }
            }
            
            // Controller skin doesn't exist, so fall back to standard controller skin
            
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == YES", #keyPath(ControllerSkin.gameType), system.gameType.rawValue, #keyPath(ControllerSkin.isStandard))
            
            if let controllerSkin = try DatabaseManager.shared.viewContext.fetch(fetchRequest).first
            {
                Settings.setPreferredControllerSkin(controllerSkin, for: system, traits: traits)
                return controllerSkin
            }
        }
        catch
        {
            print(error)
        }
        
        return nil
    }
    
    static func setPreferredControllerSkin(_ controllerSkin: ControllerSkin?, for system: System, traits: DeltaCore.ControllerSkin.Traits)
    {
        guard let userDefaultKey = self.preferredControllerSkinKey(for: system, traits: traits) else { return }
        
        guard UserDefaults.standard.string(forKey: userDefaultKey) != controllerSkin?.identifier else { return }
        
        UserDefaults.standard.set(controllerSkin?.identifier, forKey: userDefaultKey)
        
        NotificationCenter.default.post(name: Settings.didChangeNotification, object: controllerSkin, userInfo: [NotificationUserInfoKey.name: Name.preferredControllerSkin, NotificationUserInfoKey.system: system, NotificationUserInfoKey.traits: traits])
    }
    
    static func preferredControllerSkin(for game: Game, traits: DeltaCore.ControllerSkin.Traits) -> ControllerSkin?
    {
        let preferredControllerSkin: ControllerSkin?
        
        switch traits.orientation
        {
        case .portrait: preferredControllerSkin = game.preferredPortraitSkin
        case .landscape: preferredControllerSkin = game.preferredLandscapeSkin
        }
        
        let alt = AdvancedFeatures.shared.skinDebug.useAlt
        if let controllerSkin = preferredControllerSkin, let _ = controllerSkin.supportedTraits(for: traits, alt: alt)
        {
            // Check if there are supported traits, which includes fallback traits for X <-> non-X devices.
            return controllerSkin
        }
        
        if let system = System(gameType: game.type)
        {
            // Fall back to using preferred controller skin for the system.
            let controllerSkin = Settings.preferredControllerSkin(for: system, traits: traits)
            return controllerSkin
        }
                
        return nil
    }
    
    static func setPreferredControllerSkin(_ controllerSkin: ControllerSkin?, for game: Game, traits: DeltaCore.ControllerSkin.Traits)
    {
        let context = DatabaseManager.shared.newBackgroundContext()
        context.performAndWait {
            let game = context.object(with: game.objectID) as! Game
            
            let skin: ControllerSkin?
            if let controllerSkin = controllerSkin, let contextSkin = context.object(with: controllerSkin.objectID) as? ControllerSkin
            {
                skin = contextSkin
            }
            else
            {
                skin = nil
            }            
            
            switch traits.orientation
            {
            case .portrait: game.preferredPortraitSkin = skin
            case .landscape: game.preferredLandscapeSkin = skin
            }
            
            context.saveWithErrorLogging()
        }
        
        game.managedObjectContext?.refresh(game, mergeChanges: false)
        
        if let system = System(gameType: game.type)
        {
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: controllerSkin, userInfo: [NotificationUserInfoKey.name: Name.preferredControllerSkin, NotificationUserInfoKey.system: system, NotificationUserInfoKey.traits: traits])
        }
    }
}

extension Settings
{
    static func preferredCoreSettingsKey(for gameType: GameType) -> String
    {
        let key = "core." + gameType.rawValue
        return key
    }
}

private extension Settings
{
    static func preferredControllerSkinKey(for system: System, traits: DeltaCore.ControllerSkin.Traits) -> String?
    {
        let systemName: String
        
        switch system
        {
        case .nes: systemName = "nes"
        case .snes: systemName = "snes"
        case .gbc: systemName = "gbc"
        case .gba: systemName = "gba"
        case .n64: systemName = "n64"
        case .ds: systemName = "ds"
        case .genesis: systemName = "genesis"
        }
        
        let orientation: String
        
        switch traits.orientation
        {
        case .portrait: orientation = "portrait"
        case .landscape: orientation = "landscape"
        }
        
        let displayType: String
        
        switch traits.displayType
        {
        case .standard: displayType = "standard"
        case .edgeToEdge: displayType = "standard" // In this context, standard and edge-to-edge skins are treated the same.
        case .splitView: displayType = "splitview"
        }
        
        let key = systemName + "-" + orientation + "-" + displayType + "-controller"
        return key
    }
}

private extension UserDefaults
{
    @NSManaged var lastUpdateShown: Int
    
    @NSManaged var previousGameCollectionIdentifier: String?
    
    @NSManaged var gameShortcutsMode: String
    @NSManaged var gameShortcutIdentifiers: [String]
    
    @NSManaged var syncingService: String?
    
    @NSManaged var sortSaveStatesByOldestFirst: Bool
    
    @NSManaged var isAltJITEnabled: Bool
}
