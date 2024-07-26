//
//  DatabaseManager.swift
//  Ignited
//
//  Created by Riley Testut on 10/4/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import Foundation
import CoreData

// Workspace
import DeltaCore
import Harmony
import Roxas
import ZIPFoundation
import MelonDSDeltaCore

extension DatabaseManager
{
    static let didStartNotification = Notification.Name("databaseManagerDidStartNotification")
}

extension DatabaseManager
{
    enum ImportError: LocalizedError, Hashable, Equatable
    {
        case doesNotExist(URL)
        case invalid(URL)
        case unsupported(URL)
        case unknown(URL, NSError)
        case saveFailed(Set<URL>, NSError)
        
        var errorDescription: String? {
            switch self
            {
            case .doesNotExist: return NSLocalizedString("The file does not exist.", comment: "")
            case .invalid: return NSLocalizedString("The file is invalid.", comment: "")
            case .unsupported: return NSLocalizedString("This file is not supported.", comment: "")
            case .unknown(_, let error): return error.localizedDescription
            case .saveFailed(_, let error): return error.localizedDescription
            }
        }
    }
}

final class DatabaseManager: RSTPersistentContainer
{
    static let shared = DatabaseManager()
    
    private(set) var isStarted = false
    
    private var gamesDatabase: GamesDatabase? = nil
    
    private var validationManagedObjectContext: NSManagedObjectContext?
    
    private let importController = ImportController(documentTypes: [])
    
    private init()
    {
        guard
            let modelURL = Bundle(for: DatabaseManager.self).url(forResource: "Ignited", withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL),
            let harmonyModel = NSManagedObjectModel.harmonyModel(byMergingWith: [managedObjectModel])
        else { fatalError("Core Data model cannot be found. Aborting.") }
        
        super.init(name: "Ignited", managedObjectModel: harmonyModel)
        
        self.shouldAddStoresAsynchronously = true
    }
}

extension DatabaseManager
{
    func start(completionHandler: @escaping (Error?) -> Void)
    {
        guard !self.isStarted else { return }
        
        for description in self.persistentStoreDescriptions
        {
            // Set configuration so RSTPersistentContainer can determine how to migrate this and Harmony's database independently.
            description.configuration = NSManagedObjectModel.Configuration.external.rawValue
        }
        
        self.loadPersistentStores { (description, error) in
            guard error == nil else { return completionHandler(error) }
            
            self.prepareDatabase {
                self.isStarted = true
                
                NotificationCenter.default.post(name: DatabaseManager.didStartNotification, object: self)
                
                completionHandler(nil)
            }
        }
    }
    
    func prepare(_ core: DeltaCoreProtocol, in context: NSManagedObjectContext)
    {
        guard let system = System(gameType: core.gameType) else { return }
        
        if let skin = ControllerSkin(system: system, context: context)
        {
            print("Updated default skin (\(skin.identifier)) for system:", system)
        }
        else
        {
            print("Failed to update default skin for system:", system)
        }
        
        switch system
        {
        case .ds where core == MelonDS.core:
            
            // Returns nil if game already exists.
            func makeBIOS(name: String, identifier: String) -> Game?
            {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(Game.identifier), identifier)
                if let _ = Game.instancesWithPredicate(predicate, inManagedObjectContext: context, type: Game.self).first
                {
                    // BIOS already exists, so don't do anything.
                    return nil
                }
                
                let filename: String
                
                switch identifier
                {
                case Game.melonDSBIOSIdentifier:
                    guard
                        FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.bios7URL.path) &&
                        FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.bios9URL.path) &&
                        FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.firmwareURL.path)
                    else { return nil }
                    
                    filename = "nds.bios"
                    
                case Game.melonDSDSiBIOSIdentifier:
                    guard
                        FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiBIOS7URL.path) &&
                        FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiBIOS9URL.path) &&
                        FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiFirmwareURL.path) &&
                        FileManager.default.fileExists(atPath: MelonDSEmulatorBridge.shared.dsiNANDURL.path)
                    else { return nil }
                    
                    filename = "dsi.bios"
                
                default: filename = "system.bios"
                }
                
                let bios = Game(context: context)
                bios.name = name
                bios.identifier = identifier
                bios.type = .ds
                bios.filename = filename
                
                var artworkURL: URL? = nil
                
                if let artwork = UIImage(named: "DS"),
                   let artworkData = artwork.pngData()
                {
                    do
                    {
                        artworkURL = DatabaseManager.artworkURL(for: bios)
                        try artworkData.write(to: artworkURL!, options: .atomic)
                    }
                    catch
                    {
                        print("Failed to copy default DS home screen artwork.", error)
                    }
                }
                
                bios.artworkURL = artworkURL
                
                return bios
            }
            
            let insertedGames = [
                (name: NSLocalizedString("DS Home Screen", comment: ""), identifier: Game.melonDSBIOSIdentifier),
                (name: NSLocalizedString("DSi Home Screen (Beta)", comment: ""), identifier: Game.melonDSDSiBIOSIdentifier)
            ].compactMap(makeBIOS)
            
            // Break if we didn't create any new Games.
            guard !insertedGames.isEmpty else { break }
            
            let gameCollection = GameCollection(context: context)
            gameCollection.identifier = GameType.ds.rawValue
            gameCollection.index = Int16(System.ds.year)
            gameCollection.games.formUnion(insertedGames)
            
        case .ds:
            let predicate = NSPredicate(format: "%K IN %@", #keyPath(Game.identifier), [Game.melonDSBIOSIdentifier, Game.melonDSDSiBIOSIdentifier])
            
            let games = Game.instancesWithPredicate(predicate, inManagedObjectContext: context, type: Game.self)
            for game in games
            {
                context.delete(game)
            }
            
        default: break
        }
    }
}

//MARK: - Update -
private extension DatabaseManager
{
    func updateRecentGameShortcuts()
    {
        guard let managedObjectContext = self.validationManagedObjectContext else { return }
        
        guard Settings.gameShortcutsMode == .recent else { return }
        
        let fetchRequest = Game.recentlyPlayedFetchRequest
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let games = try managedObjectContext.fetch(fetchRequest)
            Settings.gameShortcuts = games
        }
        catch
        {
            print(error)
        }
    }
}

//MARK: - Preparation -
private extension DatabaseManager
{
    func prepareDatabase(completion: @escaping () -> Void)
    {
        self.validationManagedObjectContext = self.newBackgroundContext()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DatabaseManager.validateManagedObjectContextSave(with:)), name: .NSManagedObjectContextDidSave, object: nil)
        
        self.performBackgroundTask { (context) in
            
            for system in System.allCases
            {
                self.prepare(system.deltaCore, in: context)
            }
            
            do
            {
                try context.save()
            }
            catch
            {
                print("Failed to import standard controller skins:", error)
            }
            
            do
            {                
                if !FileManager.default.fileExists(atPath: DatabaseManager.gamesDatabaseURL.path) || GamesDatabase.version != GamesDatabase.previousVersion
                {
                    guard let bundleURL = Bundle.main.url(forResource: "openvgdb", withExtension: "sqlite") else { throw GamesDatabase.Error.doesNotExist }
                    try FileManager.default.copyItem(at: bundleURL, to: DatabaseManager.gamesDatabaseURL, shouldReplace: true)
                }
                
                if !FileManager.default.fileExists(atPath: DatabaseManager.cheatBaseURL.path) || CheatBase.cheatsVersion != CheatBase.previousCheatsVersion
                {
                    guard let archiveURL = Bundle.main.url(forResource: "cheatbase", withExtension: "zip") else { throw GamesDatabase.Error.doesNotExist }
                    
                    let temporaryDirectoryURL = FileManager.default.uniqueTemporaryURL()
                    try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)
                    defer {
                        try? FileManager.default.removeItem(at: temporaryDirectoryURL)
                    }
                    
                    // Unzip to temporaryDirectoryURL first to ensure we don't accidentally unzip other items into DatabaseManager.cheatBaseURL directory (e.g. __MACOSX directory).
                    try FileManager.default.unzipItem(at: archiveURL, to: temporaryDirectoryURL, skipCRC32: true) // skipCRC32 to avoid ~10 second extraction.
                    
                    let extractedDatabaseURL = temporaryDirectoryURL.appendingPathComponent("cheatbase.sqlite")
                    try FileManager.default.copyItem(at: extractedDatabaseURL, to: DatabaseManager.cheatBaseURL, shouldReplace: true)
                }
                
                self.gamesDatabase = try GamesDatabase()
            }
            catch
            {
                print(error)
            }
            
            completion()
        }
    }
}

//MARK: - Importing -
/// Importing
extension DatabaseManager
{
    func importGames(at urls: Set<URL>, completion: ((Set<Game>, Set<ImportError>) -> Void)?)
    {
        let externalFileURLs = urls.filter { !FileManager.default.isReadableFile(atPath: $0.path) }
        guard externalFileURLs.isEmpty else {
            self.importExternalFiles(at: externalFileURLs) { (importedURLs, externalImportErrors) in
                var availableFileURLs = urls.filter { !externalFileURLs.contains($0) }
                availableFileURLs.formUnion(importedURLs)
                
                self.importGames(at: Set(availableFileURLs)) { (importedGames, importErrors) in
                    let allErrors = importErrors.union(externalImportErrors)
                    completion?(importedGames, allErrors)
                }
            }
            
            return
        }
        
        let zipFileURLs = urls.filter { $0.pathExtension.lowercased() == "zip" }
        if zipFileURLs.count > 0
        {
            self.extractCompressedGames(at: Set(zipFileURLs)) { (extractedURLs, extractErrors) in
                let gameURLs = urls.filter { $0.pathExtension.lowercased() != "zip" } + extractedURLs
                self.importGames(at: Set(gameURLs)) { (importedGames, importErrors) in
                    let allErrors = importErrors.union(extractErrors)
                    completion?(importedGames, allErrors)
                }
            }
            
            return
        }
        
        self.performBackgroundTask { (context) in
            
            var errors = Set<ImportError>()
            var identifiers = Set<String>()
            
            for url in urls
            {
                guard FileManager.default.fileExists(atPath: url.path) else {
                    errors.insert(.doesNotExist(url))
                    continue
                }
                
                guard let gameType = GameType(fileExtension: url.pathExtension), let system = System(gameType: gameType) else {
                    errors.insert(.unsupported(url))
                    continue
                }
                
                guard System.registeredSystems.contains(system) else {
                    errors.insert(.unsupported(url))
                    continue
                }
                
                let identifier: String
                
                do
                {
                    identifier = try RSTHasher.sha1HashOfFile(at: url)
                }
                catch let error as NSError
                {
                    errors.insert(.unknown(url, error))
                    continue
                }
                
                let filename = identifier + "." + url.pathExtension
                
                let game = Game(context: context)
                game.identifier = identifier
                game.type = gameType
                game.filename = filename
                
                var gameName = url.deletingPathExtension().lastPathComponent
                if Settings.libraryFeatures.importing.sanitize
                {
                    gameName = gameName.sanitize(with: .parenthesis)
                }
                
                let databaseMetadata = self.gamesDatabase?.metadata(for: game)
                
                game.name = databaseMetadata?.name ?? gameName
                
                if let artworkURL = databaseMetadata?.artworkURL
                {
                    game.artworkURL = artworkURL
                }
                else
                {
                    var artwork: UIImage? = nil
                    
                    switch gameType
                    {
                    case .nes: artwork = UIImage(named: "NES")
                    case .snes: artwork = UIImage(named: "SNES")
                    case .n64: artwork = UIImage(named: "N64")
                    case .gbc where url.pathExtension.lowercased() == "gb": artwork = UIImage(named: "GB")
                    case .gbc where url.pathExtension.lowercased() == "gbc": artwork = UIImage(named: "GBC")
                    case .gba: artwork = UIImage(named: "GBA")
                    case .ds: artwork = UIImage(named: "DS")
                    case .genesis: artwork = UIImage(named: "GEN")
                    case .ms: artwork = UIImage(named: "MS")
                    case .gg: artwork = UIImage(named: "GG")
                    default: break
                    }
                    
                    if let artworkData = artwork?.pngData()
                    {
                        do
                        {
                            let artworkURL = DatabaseManager.artworkURL(for: game)
                            try artworkData.write(to: artworkURL, options: .atomic)
                            game.artworkURL = artworkURL
                        }
                        catch
                        {
                            print("Failed to copy default DS home screen artwork.", error)
                        }
                    }
                }
                
                let gameCollection = GameCollection(context: context)
                gameCollection.identifier = gameType.rawValue
                gameCollection.index = Int16(system.year)
                gameCollection.games.insert(game)
                
                do
                {
                    let destinationURL = DatabaseManager.gamesDirectoryURL.appendingPathComponent(filename)
                    
                    if FileManager.default.fileExists(atPath: destinationURL.path)
                    {
                        // Game already exists, so we choose not to override it and just delete the new game instead
                        try FileManager.default.removeItem(at: url)
                    }
                    else
                    {
                        try FileManager.default.moveItem(at: url, to: destinationURL)
                    }
                    
                    identifiers.insert(game.identifier)
                }
                catch let error as NSError
                {
                    print("Import Games error:", error)
                    game.managedObjectContext?.delete(game)
                    
                    errors.insert(.unknown(url, error))
                }
            }

            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print("Failed to save import context:", error)
                
                identifiers.removeAll()
                
                errors.insert(.saveFailed(urls, error))
            }
            
            DatabaseManager.shared.viewContext.perform {
                let predicate = NSPredicate(format: "%K IN (%@)", #keyPath(Game.identifier), identifiers)
                let games = Game.instancesWithPredicate(predicate, inManagedObjectContext: DatabaseManager.shared.viewContext, type: Game.self)
                completion?(Set(games), errors)
            }
        }
    }
    
    func importControllerSkins(at urls: Set<URL>, completion: ((Set<ControllerSkin>, Set<ImportError>) -> Void)?)
    {
        let externalFileURLs = urls.filter { !FileManager.default.isReadableFile(atPath: $0.path) }
        guard externalFileURLs.isEmpty else {
            self.importExternalFiles(at: externalFileURLs) { (importedURLs, externalImportErrors) in
                var availableFileURLs = urls.filter { !externalFileURLs.contains($0) }
                availableFileURLs.formUnion(importedURLs)
                
                self.importControllerSkins(at: Set(availableFileURLs)) { (importedSkins, importErrors) in
                    let allErrors = importErrors.union(externalImportErrors)
                    completion?(importedSkins, allErrors)
                }
            }
            
            return
        }
        
        self.performBackgroundTask { (context) in
            
            var errors = Set<ImportError>()
            var identifiers = Set<String>()
            
            for url in urls
            {
                guard FileManager.default.fileExists(atPath: url.path) else {
                    errors.insert(.doesNotExist(url))
                    continue
                }
                
                guard let deltaControllerSkin = DeltaCore.ControllerSkin(fileURL: url) else {
                    errors.insert(.invalid(url))
                    continue
                }
                
                let controllerSkin = ControllerSkin(context: context)
                controllerSkin.filename = deltaControllerSkin.identifier + "." + url.pathExtension
                
                controllerSkin.configure(with: deltaControllerSkin)
                                
                do
                {
                    if FileManager.default.fileExists(atPath: controllerSkin.fileURL.path)
                    {
                        // Normally we'd replace item instead of delete + move, but it's crashing as of iOS 10
                        // FileManager.default.replaceItemAt(controllerSkin.fileURL, withItemAt: url)
                        
                        // Controller skin exists, but we replace it with the new skin
                        try FileManager.default.removeItem(at: controllerSkin.fileURL)
                    }
                    
                    try FileManager.default.moveItem(at: url, to: controllerSkin.fileURL)
                    
                    identifiers.insert(controllerSkin.identifier)
                }
                catch let error as NSError
                {
                    print("Import Controller Skins error:", error)
                    controllerSkin.managedObjectContext?.delete(controllerSkin)
                    
                    errors.insert(.unknown(url, error))
                }
            }
            
            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print("Failed to save controller skin import context:", error)
                
                identifiers.removeAll()
                
                errors.insert(.saveFailed(urls, error))
            }
            
            DatabaseManager.shared.viewContext.perform {
                let predicate = NSPredicate(format: "%K IN (%@)", #keyPath(Game.identifier), identifiers)
                let controllerSkins = ControllerSkin.instancesWithPredicate(predicate, inManagedObjectContext: DatabaseManager.shared.viewContext, type: ControllerSkin.self)
                completion?(Set(controllerSkins), errors)
            }
        }
    }
    
    func importFromFolder(completionHandler: @escaping (Set<URL>?) -> Void)
    {
        var importedURLs = Set<URL>()
        
        let documentsDirectoryURL = DatabaseManager.importDirectoryURL
        
        do
        {
            let contents = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            let itemURLs = contents.filter { GameType(fileExtension: $0.pathExtension) != nil || $0.pathExtension.lowercased() == "zip" || $0.pathExtension.lowercased() == "deltaskin" || $0.pathExtension.lowercased() == "ignitedskin" }
            
            for url in itemURLs
            {
                let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                
                do
                {
                    if FileManager.default.fileExists(atPath: destinationURL.path)
                    {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    
                    try FileManager.default.moveItem(at: url, to: destinationURL)
                    importedURLs.insert(destinationURL)
                }
                catch
                {
                    print("Error importing file at URL", url, error)
                }
            }
            
        }
        catch
        {
            print(error)
        }
        
        completionHandler(importedURLs)
    }
    
    private func extractCompressedGames(at urls: Set<URL>, completion: @escaping ((Set<URL>, Set<ImportError>) -> Void))
    {
        DispatchQueue.global().async {
            
            var outputURLs = Set<URL>()
            var errors = Set<ImportError>()
            
            for url in urls
            {
                var archiveContainsValidGameFile = false
                
                guard let archive = Archive(url: url, accessMode: .read) else {
                    errors.insert(.invalid(url))
                    continue
                }
                
                for entry in archive
                {
                    do
                    {
                        // Ensure entry is not in a subdirectory
                        guard !entry.path.contains("/") else { continue }
                        
                        let fileExtension = (entry.path as NSString).pathExtension
                        
                        guard GameType(fileExtension: fileExtension) != nil else { continue }
                        
                        // At least one entry is a valid game file, so we set archiveContainsValidGameFile to true
                        // This will result in this archive being considered valid, and thus we will not return an ImportError.invalid error for the archive
                        // However, if this game file does turn out to be invalid when extracting, we'll return an ImportError.invalid error specific to this game file
                        archiveContainsValidGameFile = true
                        
                        // Must use temporary directory, and not the directory containing zip file, since the latter might be read-only (such as when importing from Safari)
                        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(entry.path)
                        
                        if FileManager.default.fileExists(atPath: outputURL.path)
                        {
                            try FileManager.default.removeItem(at: outputURL)
                        }
                        
                        _ = try archive.extract(entry, to: outputURL, skipCRC32: true)
                        
                        outputURLs.insert(outputURL)
                    }
                    catch
                    {
                        print(error)
                    }
                }
                
                if !archiveContainsValidGameFile
                {
                    errors.insert(.invalid(url))
                }
            }
            
            for url in urls
            {
                if FileManager.default.fileExists(atPath: url.path)
                {
                    do
                    {
                        try FileManager.default.removeItem(at: url)
                    }
                    catch
                    {
                        print(error)
                    }
                }
            }
            
            completion(outputURLs, errors)
        }
    }
    
    private func importExternalFiles(at urls: Set<URL>, completion: @escaping ((Set<URL>, Set<ImportError>) -> Void))
    {
        var outputURLs = Set<URL>()
        var errors = Set<ImportError>()
        
        let dispatchGroup = DispatchGroup()
        for url in urls
        {
            dispatchGroup.enter()
            
            self.importController.importExternalFile(at: url) { (result) in
                switch result
                {
                case .failure(let error): errors.insert(.unknown(url, error as NSError))
                case .success(let fileURL): outputURLs.insert(fileURL)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            completion(outputURLs, errors)
        }
    }
    
    func resetArtwork(for game: Game)
    {
        self.performBackgroundTask { (context) in
            
            let game = context.object(with: game.objectID) as! Game
            
            let databaseMetadata = self.gamesDatabase?.metadata(for: game)
            if let artworkURL = databaseMetadata?.artworkURL
            {
                game.artworkURL = artworkURL
            }
            else if game.artworkURL == nil
            {
                var artwork: UIImage? = nil
                
                switch game.type
                {
                case .nes: artwork = UIImage(named: "NES")
                case .snes: artwork = UIImage(named: "SNES")
                case .n64: artwork = UIImage(named: "N64")
                case .gbc where game.fileURL.pathExtension.lowercased() == "gb": artwork = UIImage(named: "GB")
                case .gbc where game.fileURL.pathExtension.lowercased() == "gbc": artwork = UIImage(named: "GBC")
                case .gba: artwork = UIImage(named: "GBA")
                case .ds: artwork = UIImage(named: "DS")
                case .genesis: artwork = UIImage(named: "GEN")
                case .ms: artwork = UIImage(named: "MS")
                case .gg: artwork = UIImage(named: "GG")
                default: break
                }
                
                if let artworkData = artwork?.pngData()
                {
                    do
                    {
                        let artworkURL = DatabaseManager.artworkURL(for: game)
                        try artworkData.write(to: artworkURL, options: .atomic)
                        game.artworkURL = artworkURL
                    }
                    catch
                    {
                        print("Failed to copy default DS home screen artwork.", error)
                    }
                }
            }
            context.saveWithErrorLogging()
        }
    }
    
    func resetPlaytime(for game: Game)
    {
        self.performBackgroundTask { (context) in
            
            let game = context.object(with: game.objectID) as! Game
            
            game.playedDate = nil
            game.playTime = 0
            
            context.saveWithErrorLogging()
            
            WidgetManager.refresh()
        }
    }
    
    func repairGameCollections(repairAll: Bool = false)
    {
        let gameFetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        gameFetchRequest.returnsObjectsAsFaults = false
        
        let gameCollectionFetchRequest: NSFetchRequest<GameCollection> = GameCollection.fetchRequest()
        gameCollectionFetchRequest.returnsObjectsAsFaults = false
        
        self.performBackgroundTask { (context) in
            do
            {
                let games = try gameFetchRequest.execute()
                
                for game in games
                {
                    let temporaryGame = context.object(with: game.objectID) as! Game
                    
                    guard game.identifier != Game.legacyMelonDSBIOSIdentifier,
                          game.identifier != Game.legacyMelonDSDSiBIOSIdentifier else
                    {
                        context.delete(temporaryGame)
                        continue
                    }
                    
                    guard let gameType = GameType(fileExtension: game.fileURL.pathExtension),
                          (gameType.rawValue != game.type.rawValue) || repairAll else
                    {
                        continue
                    }
                    
                    let gameCollection = GameCollection(context: context)
                    gameCollection.identifier = gameType.rawValue
                    gameCollection.index = Int16(System(gameType: gameType)?.year ?? 2000)
                    gameCollection.games.insert(game)
                    
                    game.type = gameType
                }
                
                context.saveWithErrorLogging()
                
                let gameCollections = try gameCollectionFetchRequest.execute()
                
                for gameCollection in gameCollections
                {
                    if gameCollection.games.isEmpty
                    {
                        let temporaryGameCollection = context.object(with: gameCollection.objectID) as! GameCollection
                        context.delete(temporaryGameCollection)
                    }
                }
                
                context.saveWithErrorLogging()
            }
            catch
            {
                print("Failed to fix game collections.")
            }
        }
    }
    
    func repairSaveStates()
    {
        let saveStateFetchRequest: NSFetchRequest<SaveState> = SaveState.fetchRequest()
        saveStateFetchRequest.returnsObjectsAsFaults = false
        
        self.performBackgroundTask { (context) in
            do
            {
                let saveStates = try saveStateFetchRequest.execute()
                
                for saveState in saveStates
                {
                    if let coreIdentifier = saveState.coreIdentifier
                    {
                        let newCoreIdentifier = coreIdentifier.replacingOccurrences(of: "rileytestut", with: "litritt")
                        
                        saveState.coreIdentifier = newCoreIdentifier
                    }
                }
                
                context.saveWithErrorLogging()
            }
            catch
            {
                print("Failed to fix save states.")
            }
        }
    }
    
    func repairDeltaSkins()
    {
        let skinFetchRequest: NSFetchRequest<ControllerSkin> = ControllerSkin.fetchRequest()
        skinFetchRequest.returnsObjectsAsFaults = false
        
        self.performBackgroundTask { (context) in
            var skinsToRepair = Set<URL>()
            
            do
            {
                let skins: [ControllerSkin] = try skinFetchRequest.execute()
                
                for skin in skins
                {
                    if skin.gameType.rawValue.hasPrefix("com.rileytestut")
                    {
                        if skin.isStandard
                        {
                            let temporarySkin = context.object(with: skin.objectID) as! ControllerSkin
                            context.delete(temporarySkin)
                        }
                        else
                        {
                            skinsToRepair.insert(skin.fileURL)
                        }
                    }
                }
                
                context.saveWithErrorLogging()
            }
            catch
            {
                print("Failed to fix Delta skins.")
            }
            
            self.importControllerSkins(at: skinsToRepair, completion: nil)
            
            self.prepareDatabase {
                Logger.database.info("Successfully prepared database and reimported standard skins.")
            }
        }
    }
}

extension DatabaseManager
{
    func patreonAccount(in context: NSManagedObjectContext = DatabaseManager.shared.viewContext) -> PatreonAccount?
    {
        let patronAccount = PatreonAccount.first(in: context)
        return patronAccount
    }
}

//MARK: - File URLs -
/// File URLs
extension DatabaseManager
{
    override class func defaultDirectoryURL() -> URL
    {
        let documentsDirectoryURL: URL
        
        if UIDevice.current.userInterfaceIdiom == .tv
        {
            documentsDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        }
        else
        {
            documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
        let databaseDirectoryURL = documentsDirectoryURL.appendingPathComponent("Database")
        self.createDirectory(at: databaseDirectoryURL)
        
        return databaseDirectoryURL
    }
    
    class var backupDirectoryURL: URL
    {
        let backupDirectoryURL = DatabaseManager.defaultDirectoryURL().appendingPathComponent("Backup")
        self.createDirectory(at: backupDirectoryURL)
        
        return backupDirectoryURL
    }
    
    class var importDirectoryURL: URL
    {
        let importDirectoryURL = DatabaseManager.defaultDirectoryURL().deletingLastPathComponent().appendingPathComponent("Import")
        self.createDirectory(at: importDirectoryURL)
        
        return importDirectoryURL
    }
    
    class var legacyDatabaseURL: URL
    {
        let backupDirectoryURL = DatabaseManager.defaultDirectoryURL().appendingPathComponent("Delta.sqlite")
        return backupDirectoryURL
    }
    
    class var gamesDatabaseURL: URL
    {
        let gamesDatabaseURL = self.defaultDirectoryURL().appendingPathComponent("openvgdb.sqlite")
        return gamesDatabaseURL
    }
    
    class var cheatBaseURL: URL
    {
        let gamesDatabaseURL = self.defaultDirectoryURL().appendingPathComponent("cheatbase.sqlite")
        return gamesDatabaseURL
    }

    class var gamesDirectoryURL: URL
    {
        let gamesDirectoryURL = DatabaseManager.defaultDirectoryURL().appendingPathComponent("Games")
        self.createDirectory(at: gamesDirectoryURL)
        
        return gamesDirectoryURL
    }
    
    class var saveStatesDirectoryURL: URL
    {
        let saveStatesDirectoryURL = DatabaseManager.defaultDirectoryURL().appendingPathComponent("Save States")
        self.createDirectory(at: saveStatesDirectoryURL)
        
        return saveStatesDirectoryURL
    }
    
    class func saveStatesDirectoryURL(for game: Game) -> URL
    {
        let gameDirectoryURL = DatabaseManager.saveStatesDirectoryURL.appendingPathComponent(game.identifier)
        self.createDirectory(at: gameDirectoryURL)
        
        return gameDirectoryURL
    }
    
    class var controllerSkinsDirectoryURL: URL
    {
        let controllerSkinsDirectoryURL = DatabaseManager.defaultDirectoryURL().appendingPathComponent("Controller Skins")
        self.createDirectory(at: controllerSkinsDirectoryURL)
        
        return controllerSkinsDirectoryURL
    }
    
    class func controllerSkinsDirectoryURL(for gameType: GameType) -> URL
    {
        let gameTypeDirectoryURL = DatabaseManager.controllerSkinsDirectoryURL.appendingPathComponent(gameType.rawValue)
        self.createDirectory(at: gameTypeDirectoryURL)
        
        return gameTypeDirectoryURL
    }
    
    class func artworkURL(for game: Game) -> URL
    {
        let gameURL = game.fileURL
        
        let artworkURL = gameURL.deletingPathExtension().appendingPathExtension("png")
        return artworkURL
    }
    
    class func artworkGifURL(for game: Game) -> URL
    {
        let gameURL = game.fileURL
        
        let artworkURL = gameURL.deletingPathExtension().appendingPathExtension("gif")
        return artworkURL
    }
}

//MARK: - Notifications -
private extension DatabaseManager
{
    @objc func validateManagedObjectContextSave(with notification: Notification)
    {
        guard (notification.object as? NSManagedObjectContext) != self.validationManagedObjectContext else { return }
        
        let insertedObjects = (notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>) ?? []
        let updatedObjects = (notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>) ?? []
        let deletedObjects = (notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>) ?? []
        
        let allObjects = insertedObjects.union(updatedObjects).union(deletedObjects)

        if allObjects.contains(where: { $0 is Game })
        {
            self.validationManagedObjectContext?.perform {
                self.updateRecentGameShortcuts()
            }
        }
    }
}

//MARK: - Private -
private extension DatabaseManager
{
    class func createDirectory(at url: URL)
    {
        do
        {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            print(error)
        }
    }
}
