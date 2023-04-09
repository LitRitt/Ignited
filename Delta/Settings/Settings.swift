//
//  Settings.swift
//  Delta
//
//  Created by Riley Testut on 8/23/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import Foundation

import DeltaCore
import MelonDSDeltaCore

import Roxas

extension Notification.Name
{
    static let settingsDidChange = Notification.Name("SettingsDidChangeNotification")
}

extension Settings
{
    enum NotificationUserInfoKey: String
    {
        case name
        
        case system
        case traits
        
        case core
    }
    
    enum Name: String
    {
        case autoLoadSave
        case gameArtworkSize
        case themeColor
        case localControllerPlayerIndex
        case translucentControllerSkinOpacity
        case preferredControllerSkin
        case syncingService
        case isButtonHapticFeedbackEnabled
        case isThumbstickHapticFeedbackEnabled
        case isClickyHapticEnabled
        case hapticFeedbackStrength
        case isButtonAudioFeedbackEnabled
        case buttonAudioFeedbackSound
        case isButtonTouchOverlayEnabled
        case touchOverlayOpacity
        case touchOverlaySize
        case isTouchOverlayThemeEnabled
        case isAltJITEnabled
        case respectSilentMode
        case isUnsafeFastForwardSpeedsEnabled
        case isPromptSpeedEnabled
        case fastForwardSpeed
        case isRewindEnabled
        case rewindTimerInterval
        case isAltRepresentationsAvailable
        case isAltRepresentationsEnabled
        case isAlwaysShowControllerSkinEnabled
        case isDebugModeEnabled
        case isSkinDebugModeEnabled
    }
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
    
    enum ButtonSoundMode: String
    {
        case system
        case snappy
        case bit8
    }
}

struct Settings
{
    static func registerDefaults()
    {
        let defaults = [#keyPath(UserDefaults.themeColor): ThemeColor.orange.rawValue,
                        #keyPath(UserDefaults.gameArtworkSize): ArtworkSize.medium.rawValue,
                        #keyPath(UserDefaults.translucentControllerSkinOpacity): 0.7,
                        #keyPath(UserDefaults.gameShortcutsMode): GameShortcutsMode.recent.rawValue,
                        #keyPath(UserDefaults.buttonAudioFeedbackSound): ButtonSoundMode.system.rawValue,
                        #keyPath(UserDefaults.isButtonHapticFeedbackEnabled): UIDevice.current.userInterfaceIdiom != .pad,
                        #keyPath(UserDefaults.isThumbstickHapticFeedbackEnabled): UIDevice.current.userInterfaceIdiom != .pad,
                        #keyPath(UserDefaults.isClickyHapticEnabled): UIDevice.current.userInterfaceIdiom != .pad,
                        #keyPath(UserDefaults.hapticFeedbackStrength): 1.0,
                        #keyPath(UserDefaults.isButtonTouchOverlayEnabled): UIDevice.current.userInterfaceIdiom == .pad,
                        #keyPath(UserDefaults.isTouchOverlayThemeEnabled): true,
                        #keyPath(UserDefaults.touchOverlayOpacity): 0.7,
                        #keyPath(UserDefaults.touchOverlaySize): 1.0,
                        #keyPath(UserDefaults.sortSaveStatesByOldestFirst): true,
                        #keyPath(UserDefaults.isPreviewsEnabled): true,
                        #keyPath(UserDefaults.isAltJITEnabled): false,
                        #keyPath(UserDefaults.autoLoadSave): true,
                        #keyPath(UserDefaults.showToastNotifications): true,
                        #keyPath(UserDefaults.respectSilentMode): true,
                        #keyPath(UserDefaults.isButtonAudioFeedbackEnabled): false,
                        #keyPath(UserDefaults.isRewindEnabled): true,
                        #keyPath(UserDefaults.rewindTimerInterval): 15,
                        #keyPath(UserDefaults.isUnsafeFastForwardSpeedsEnabled): false,
                        #keyPath(UserDefaults.isPromptSpeedEnabled): true,
                        #keyPath(UserDefaults.fastForwardSpeed): 4.0,
                        #keyPath(UserDefaults.isUseAltRepresentationsEnabled): false,
                        #keyPath(UserDefaults.isAltRepresentationsAvailable): false,
                        #keyPath(UserDefaults.isAlwaysShowControllerSkinEnabled): false,
                        #keyPath(UserDefaults.isDebugModeEnabled): false,
                        #keyPath(UserDefaults.isSkinDebugModeEnabled): false,
                        Settings.preferredCoreSettingsKey(for: .ds): MelonDS.core.identifier] as [String : Any]
        UserDefaults.standard.register(defaults: defaults)
    }
}

extension Settings
{
    /// Theme
    static var themeColor: ThemeColor {
        set {
            UserDefaults.standard.themeColor = newValue.rawValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.themeColor])
        }
        get {
            let theme = ThemeColor(rawValue: UserDefaults.standard.themeColor) ?? .orange
            return theme
        }
    }
    
    /// Artwork
    static var gameArtworkSize: ArtworkSize {
        set {
            UserDefaults.standard.gameArtworkSize = newValue.rawValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.gameArtworkSize])
        }
        get {
            let size = ArtworkSize(rawValue: UserDefaults.standard.gameArtworkSize) ?? .medium
            return size
        }
    }
    
    /// Controllers
    static var localControllerPlayerIndex: Int? = 0 {
        didSet {
            guard self.localControllerPlayerIndex != oldValue else { return }
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.localControllerPlayerIndex])
        }
    }
    
    static var translucentControllerSkinOpacity: CGFloat {
        set {
            guard newValue != self.translucentControllerSkinOpacity else { return }
            UserDefaults.standard.translucentControllerSkinOpacity = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.translucentControllerSkinOpacity])
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
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.syncingService])
        }
    }
    
    static var isButtonHapticFeedbackEnabled: Bool {
        get {
            let isEnabled = UserDefaults.standard.isButtonHapticFeedbackEnabled
            return isEnabled
        }
        set {
            UserDefaults.standard.isButtonHapticFeedbackEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isButtonHapticFeedbackEnabled])
        }
    }
    
    static var isThumbstickHapticFeedbackEnabled: Bool {
        get {
            let isEnabled = UserDefaults.standard.isThumbstickHapticFeedbackEnabled
            return isEnabled
        }
        set {
            UserDefaults.standard.isThumbstickHapticFeedbackEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isThumbstickHapticFeedbackEnabled])
        }
    }
    
    static var isClickyHapticEnabled: Bool {
        get {
            let isEnabled = UserDefaults.standard.isClickyHapticEnabled
            return isEnabled
        }
        set {
            UserDefaults.standard.isClickyHapticEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isClickyHapticEnabled])
        }
    }
    
    static var hapticFeedbackStrength: CGFloat {
        set {
            guard newValue != self.hapticFeedbackStrength else { return }
            UserDefaults.standard.hapticFeedbackStrength = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.hapticFeedbackStrength])
        }
        get { return UserDefaults.standard.hapticFeedbackStrength }
    }
    
    static var isButtonAudioFeedbackEnabled: Bool {
        get {
            let isEnabled = UserDefaults.standard.isButtonAudioFeedbackEnabled
            return isEnabled
        }
        set {
            UserDefaults.standard.isButtonAudioFeedbackEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isButtonAudioFeedbackEnabled])
        }
    }
    
    static var buttonAudioFeedbackSound: ButtonSoundMode {
        set {
            UserDefaults.standard.buttonAudioFeedbackSound = newValue.rawValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.buttonAudioFeedbackSound])
        }
        get {
            let size = ButtonSoundMode(rawValue: UserDefaults.standard.buttonAudioFeedbackSound) ?? .system
            return size
        }
    }
    
    static var isButtonTouchOverlayEnabled: Bool {
        get {
            let isEnabled = UserDefaults.standard.isButtonTouchOverlayEnabled
            return isEnabled
        }
        set {
            UserDefaults.standard.isButtonTouchOverlayEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isButtonTouchOverlayEnabled])
        }
    }
    
    static var isTouchOverlayThemeEnabled: Bool {
        get {
            let isEnabled = UserDefaults.standard.isTouchOverlayThemeEnabled
            return isEnabled
        }
        set {
            UserDefaults.standard.isTouchOverlayThemeEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isTouchOverlayThemeEnabled])
        }
    }
    
    static var touchOverlayOpacity: CGFloat {
        set {
            guard newValue != self.touchOverlayOpacity else { return }
            UserDefaults.standard.touchOverlayOpacity = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.touchOverlayOpacity])
        }
        get { return UserDefaults.standard.touchOverlayOpacity }
    }
    
    static var touchOverlaySize: CGFloat {
        set {
            guard newValue != self.touchOverlaySize else { return }
            UserDefaults.standard.touchOverlaySize = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.touchOverlaySize])
        }
        get { return UserDefaults.standard.touchOverlaySize }
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
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltJITEnabled])
        }
    }
    
    static var showToastNotifications: Bool {
        get {
            let showToastNotifications = UserDefaults.standard.showToastNotifications
            return showToastNotifications
        }
        set {
            UserDefaults.standard.showToastNotifications = newValue
        }
    }
    
    static var autoLoadSave: Bool {
        get {
            let autoLoadSave = UserDefaults.standard.autoLoadSave
            return autoLoadSave
        }
        set {
            UserDefaults.standard.autoLoadSave = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.autoLoadSave])
        }
    }
    
    static var respectSilentMode: Bool {
        get {
            let respectSilentMode = UserDefaults.standard.respectSilentMode
            return respectSilentMode
        }
        set {
            UserDefaults.standard.respectSilentMode = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.respectSilentMode])
        }
    }
    
    static var isRewindEnabled: Bool {
        set {
            UserDefaults.standard.isRewindEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isRewindEnabled])
        }
        get {
            let isRewindEnabled = UserDefaults.standard.isRewindEnabled
            return isRewindEnabled
        }
    }
    
    static var rewindTimerInterval: Int {
        set {
            UserDefaults.standard.rewindTimerInterval = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.rewindTimerInterval])
            
        }
        get {
            let rewindTimerInterval = UserDefaults.standard.rewindTimerInterval
            return rewindTimerInterval
        }
    }
    
    static var isUnsafeFastForwardSpeedsEnabled: Bool {
        set {
            UserDefaults.standard.isUnsafeFastForwardSpeedsEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isUnsafeFastForwardSpeedsEnabled])
        }
        get {
            let isUnsafeFastForwardSpeedsEnabled = UserDefaults.standard.isUnsafeFastForwardSpeedsEnabled
            return isUnsafeFastForwardSpeedsEnabled
        }
    }
    
    static var isPromptSpeedEnabled: Bool {
        set {
            UserDefaults.standard.isPromptSpeedEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isPromptSpeedEnabled])
        }
        get {
            let isSpeedPromptEnabled = UserDefaults.standard.isPromptSpeedEnabled
            return isSpeedPromptEnabled
        }
    }
    
    static var fastForwardSpeed: CGFloat {
        set {
            UserDefaults.standard.fastForwardSpeed = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.fastForwardSpeed])
            
        }
        get {
            let fastForwardSpeed = UserDefaults.standard.fastForwardSpeed
            return fastForwardSpeed
        }
    }
    
    static var isAltRepresentationsEnabled: Bool {
        set {
            UserDefaults.standard.isUseAltRepresentationsEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltRepresentationsEnabled])
        }
        get {
            let isUseAltRepresentationsEnabled = UserDefaults.standard.isUseAltRepresentationsEnabled
            return isUseAltRepresentationsEnabled
        }
    }
    
    static var isAltRepresentationsAvailable: Bool {
        set {
            UserDefaults.standard.isAltRepresentationsAvailable = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltRepresentationsAvailable])
        }
        get {
            let isAltRepresentationsAvailable = UserDefaults.standard.isAltRepresentationsAvailable
            return isAltRepresentationsAvailable
        }
    }
    
    static var isAlwaysShowControllerSkinEnabled: Bool {
        set {
            UserDefaults.standard.isAlwaysShowControllerSkinEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAlwaysShowControllerSkinEnabled])
        }
        get {
            let isAlwaysShowControllerSkinEnabled = UserDefaults.standard.isAlwaysShowControllerSkinEnabled
            return isAlwaysShowControllerSkinEnabled
        }
    }
    
    static var isDebugModeEnabled: Bool {
        set {
            UserDefaults.standard.isDebugModeEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isDebugModeEnabled])
        }
        get {
            let isDebugModeEnabled = UserDefaults.standard.isDebugModeEnabled
            return isDebugModeEnabled
        }
    }
    
    static var isSkinDebugModeEnabled: Bool {
        set {
            UserDefaults.standard.isSkinDebugModeEnabled = newValue
            NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isSkinDebugModeEnabled])
        }
        get {
            let isSkinDebugModeEnabled = UserDefaults.standard.isSkinDebugModeEnabled
            return isSkinDebugModeEnabled
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
        NotificationCenter.default.post(name: .settingsDidChange, object: nil, userInfo: [NotificationUserInfoKey.name: key, NotificationUserInfoKey.core: core])
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
        
        NotificationCenter.default.post(name: .settingsDidChange, object: controllerSkin, userInfo: [NotificationUserInfoKey.name: Name.preferredControllerSkin, NotificationUserInfoKey.system: system, NotificationUserInfoKey.traits: traits])
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
            NotificationCenter.default.post(name: .settingsDidChange, object: controllerSkin, userInfo: [NotificationUserInfoKey.name: Name.preferredControllerSkin, NotificationUserInfoKey.system: system, NotificationUserInfoKey.traits: traits])
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
    @NSManaged var themeColor: String
    @NSManaged var gameArtworkSize: String
    
    @NSManaged var translucentControllerSkinOpacity: CGFloat
    @NSManaged var previousGameCollectionIdentifier: String?
    
    @NSManaged var gameShortcutsMode: String
    @NSManaged var gameShortcutIdentifiers: [String]
    
    @NSManaged var syncingService: String?
    
    @NSManaged var isButtonHapticFeedbackEnabled: Bool
    @NSManaged var isThumbstickHapticFeedbackEnabled: Bool
    @NSManaged var isClickyHapticEnabled: Bool
    @NSManaged var hapticFeedbackStrength: CGFloat
    
    @NSManaged var isButtonAudioFeedbackEnabled: Bool
    @NSManaged var buttonAudioFeedbackSound: String
    
    @NSManaged var isButtonTouchOverlayEnabled: Bool
    @NSManaged var isTouchOverlayThemeEnabled: Bool
    @NSManaged var touchOverlayOpacity: CGFloat
    @NSManaged var touchOverlaySize: CGFloat
    
    @NSManaged var sortSaveStatesByOldestFirst: Bool
    
    @NSManaged var isPreviewsEnabled: Bool
    
    @NSManaged var isAltJITEnabled: Bool
    
    @NSManaged var showToastNotifications: Bool
    @NSManaged var autoLoadSave: Bool
    @NSManaged var respectSilentMode: Bool
    @NSManaged var isRewindEnabled: Bool
    @NSManaged var rewindTimerInterval: Int
    
    @NSManaged var isUnsafeFastForwardSpeedsEnabled: Bool
    @NSManaged var isPromptSpeedEnabled: Bool
    @NSManaged var fastForwardSpeed: CGFloat
    
    @NSManaged var isUseAltRepresentationsEnabled: Bool
    @NSManaged var isAltRepresentationsAvailable: Bool
    @NSManaged var isAlwaysShowControllerSkinEnabled: Bool
    
    @NSManaged var isDebugModeEnabled: Bool
    @NSManaged var isSkinDebugModeEnabled: Bool
}
