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
    static let translucentControllerSkinOpacity: Settings.Name = "translucentControllerSkinOpacity"
    static let preferredControllerSkin: Settings.Name = "preferredControllerSkin"
    static let syncingService: Settings.Name = "syncingService"
    static let isAltJITEnabled: Settings.Name = "isAltJITEnabled"
    static let gameArtworkSize: Settings.Name = "gameArtworkSize"
    static let themeColor: Settings.Name = "themeColor"
    static let isAltRepresentationsAvailable: Settings.Name = "isAltRepresentationsAvailable"
    static let isAltRepresentationsEnabled: Settings.Name = "isAltRepresentationsEnabled"
    static let isAlwaysShowControllerSkinEnabled: Settings.Name = "isAlwaysShowControllerSkinEnabled"
    static let isSkinDebugModeEnabled: Settings.Name = "isSkinDebugModeEnabled"
    static let skinDebugDevice: Settings.Name = "skinDebugDevice"
}

extension Settings
{
    enum GameShortcutsMode: String
    {
        case recent
        case manual
    }
    
    enum ThemeColor: String
    {
        case orange
        case purple
        case blue
        case red
        case green
        case teal
        case pink
        case yellow
        case mint
    }
    
    enum ArtworkSize: String
    {
        case small
        case medium
        case large
    }
    
    enum SkinDebugDevice: String
    {
        case standard
        case edgeToEdge
        case ipad
        case splitView
    }
    
    typealias Name = SettingsName
    typealias NotificationUserInfoKey = SettingsUserInfoKey
    
    static let didChangeNotification = Notification.Name.settingsDidChange
}

struct Settings
{
    static func registerDefaults()
    {
        let defaults = [#keyPath(UserDefaults.lastUpdateShown): 1,
                        #keyPath(UserDefaults.themeColor): ThemeColor.orange.rawValue,
                        #keyPath(UserDefaults.translucentControllerSkinOpacity): 0.7,
                        #keyPath(UserDefaults.gameShortcutsMode): GameShortcutsMode.recent.rawValue,
                        #keyPath(UserDefaults.sortSaveStatesByOldestFirst): false,
                        #keyPath(UserDefaults.isPreviewsEnabled): true,
                        #keyPath(UserDefaults.isAltJITEnabled): false,
                        #keyPath(UserDefaults.isUseAltRepresentationsEnabled): false,
                        #keyPath(UserDefaults.isAltRepresentationsAvailable): false,
                        #keyPath(UserDefaults.isAlwaysShowControllerSkinEnabled): false,
                        #keyPath(UserDefaults.isSkinDebugModeEnabled): false,
                        #keyPath(UserDefaults.skinDebugDevice): SkinDebugDevice.edgeToEdge.rawValue,
                        Settings.preferredCoreSettingsKey(for: .ds): MelonDS.core.identifier] as [String : Any]
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
    
    /// Theme
    static var themeColor: ThemeColor {
        set {
            UserDefaults.standard.themeColor = newValue.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.themeColor])
        }
        get {
            let theme = ThemeColor(rawValue: UserDefaults.standard.themeColor) ?? .orange
            return theme
        }
    }
    
    /// Controllers
    static var localControllerPlayerIndex: Int? = 0 {
        didSet {
            guard self.localControllerPlayerIndex != oldValue else { return }
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.localControllerPlayerIndex])
        }
    }
    
    static var translucentControllerSkinOpacity: CGFloat {
        set {
            guard newValue != self.translucentControllerSkinOpacity else { return }
            UserDefaults.standard.translucentControllerSkinOpacity = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.translucentControllerSkinOpacity])
        }
        get { return UserDefaults.standard.translucentControllerSkinOpacity }
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
    
    static var isPreviewsEnabled: Bool {
        set {
            UserDefaults.standard.isPreviewsEnabled = newValue
        }
        get {
            let isPreviewsEnabled = UserDefaults.standard.isPreviewsEnabled
            return isPreviewsEnabled
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
    
    static var isAltRepresentationsEnabled: Bool {
        set {
            UserDefaults.standard.isUseAltRepresentationsEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltRepresentationsEnabled])
        }
        get {
            let isUseAltRepresentationsEnabled = UserDefaults.standard.isUseAltRepresentationsEnabled
            return isUseAltRepresentationsEnabled
        }
    }
    
    static var isAltRepresentationsAvailable: Bool {
        set {
            UserDefaults.standard.isAltRepresentationsAvailable = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltRepresentationsAvailable])
        }
        get {
            let isAltRepresentationsAvailable = UserDefaults.standard.isAltRepresentationsAvailable
            return isAltRepresentationsAvailable
        }
    }
    
    static var isAlwaysShowControllerSkinEnabled: Bool {
        set {
            UserDefaults.standard.isAlwaysShowControllerSkinEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAlwaysShowControllerSkinEnabled])
        }
        get {
            let isAlwaysShowControllerSkinEnabled = UserDefaults.standard.isAlwaysShowControllerSkinEnabled
            return isAlwaysShowControllerSkinEnabled
        }
    }
    
    static var isSkinDebugModeEnabled: Bool {
        set {
            UserDefaults.standard.isSkinDebugModeEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isSkinDebugModeEnabled])
        }
        get {
            let isSkinDebugModeEnabled = UserDefaults.standard.isSkinDebugModeEnabled
            return isSkinDebugModeEnabled
        }
    }
    
    static var skinDebugDevice: SkinDebugDevice {
        set {
            UserDefaults.standard.skinDebugDevice = newValue.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.skinDebugDevice])
        }
        get {
            let device = SkinDebugDevice(rawValue: UserDefaults.standard.skinDebugDevice) ?? .edgeToEdge
            return device
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
        
        let alt = Settings.isAltRepresentationsEnabled
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
    
    @NSManaged var themeColor: String
    @NSManaged var gameArtworkSize: String
    
    @NSManaged var translucentControllerSkinOpacity: CGFloat
    @NSManaged var previousGameCollectionIdentifier: String?
    
    @NSManaged var gameShortcutsMode: String
    @NSManaged var gameShortcutIdentifiers: [String]
    
    @NSManaged var syncingService: String?
    
    @NSManaged var sortSaveStatesByOldestFirst: Bool
    
    @NSManaged var isPreviewsEnabled: Bool
    
    @NSManaged var isAltJITEnabled: Bool
    
    @NSManaged var isUseAltRepresentationsEnabled: Bool
    @NSManaged var isAltRepresentationsAvailable: Bool
    @NSManaged var isAlwaysShowControllerSkinEnabled: Bool
    
    @NSManaged var isSkinDebugModeEnabled: Bool
    @NSManaged var skinDebugDevice: String
}
